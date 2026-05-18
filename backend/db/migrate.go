package db

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"
)

// Migration represents a database migration
type Migration struct {
	Version int
	Name    string
	Up      string
	Down    string
}

// MigrationResult represents the result of running migrations
type MigrationResult struct {
	TotalApplied int
	LastVersion  int
	Errors       []error
}

// RunMigrations runs all pending migrations
func RunMigrations(migrationsPath string) (*MigrationResult, error) {
	if Pool == nil {
		return nil, fmt.Errorf("database not initialized")
	}

	// Create migrations table if it doesn't exist
	if err := createMigrationsTable(); err != nil {
		return nil, fmt.Errorf("failed to create migrations table: %w", err)
	}

	// Load all migrations
	migrations, err := loadMigrations(migrationsPath)
	if err != nil {
		return nil, fmt.Errorf("failed to load migrations: %w", err)
	}

	// Get already applied migrations
	applied, err := getAppliedMigrations()
	if err != nil {
		return nil, fmt.Errorf("failed to get applied migrations: %w", err)
	}

	// Filter out already applied migrations
	pending := getPendingMigrations(migrations, applied)

	if len(pending) == 0 {
		log.Println("No pending migrations")
		return &MigrationResult{TotalApplied: 0, LastVersion: getLatestVersion(applied)}, nil
	}

	log.Printf("Found %d pending migrations", len(pending))

	// Apply pending migrations
	result := &MigrationResult{}
	for _, migration := range pending {
		if err := applyMigration(migration); err != nil {
			result.Errors = append(result.Errors, fmt.Errorf("migration %d failed: %w", migration.Version, err))
			// Stop on first error
			break
		}
		result.TotalApplied++
		result.LastVersion = migration.Version
		log.Printf("Applied migration: %s", migration.Name)
	}

	if len(result.Errors) > 0 {
		return result, fmt.Errorf("migration failed: %v", result.Errors[0])
	}

	log.Printf("Successfully applied %d migrations", result.TotalApplied)
	return result, nil
}

// RollbackMigration rolls back the last applied migration
func RollbackMigration() error {
	if Pool == nil {
		return fmt.Errorf("database not initialized")
	}

	// Get the last applied migration
	query := `SELECT version, name FROM migrations ORDER BY version DESC LIMIT 1`
	var version int
	var name string

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err := Pool.QueryRow(ctx, query).Scan(&version, &name)
	if err != nil {
		return fmt.Errorf("no migrations to rollback: %w", err)
	}

	// Load the migration file
	migrationsPath := "migrations"
	downFile := filepath.Join(migrationsPath, fmt.Sprintf("%03d_%s.down.sql", version, name))
	downSQL, err := os.ReadFile(downFile)
	if err != nil {
		return fmt.Errorf("failed to read rollback file: %w", err)
	}

	// Execute the rollback in a transaction
	tx, err := Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	// Execute the down migration
	if _, err := tx.Exec(ctx, string(downSQL)); err != nil {
		return fmt.Errorf("failed to execute rollback: %w", err)
	}

	// Remove the migration record
	_, err = tx.Exec(ctx, "DELETE FROM migrations WHERE version = $1", version)
	if err != nil {
		return fmt.Errorf("failed to remove migration record: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit rollback: %w", err)
	}

	log.Printf("Rolled back migration: %s (version %d)", name, version)
	return nil
}

// GetMigrationStatus returns the current migration status
func GetMigrationStatus(migrationsPath string) ([]map[string]interface{}, error) {
	if Pool == nil {
		return nil, fmt.Errorf("database not initialized")
	}

	// Load all migrations
	allMigrations, err := loadMigrations(migrationsPath)
	if err != nil {
		return nil, err
	}

	// Get applied migrations
	applied, err := getAppliedMigrations()
	if err != nil {
		return nil, err
	}

	var status []map[string]interface{}
	for _, migration := range allMigrations {
		appliedTime := ""
		for _, appliedMigration := range applied {
			if appliedMigration.Version == migration.Version {
				appliedTime = appliedMigration.AppliedAt.Format(time.RFC3339)
				break
			}
		}

		status = append(status, map[string]interface{}{
			"version":     migration.Version,
			"name":        migration.Name,
			"applied":     appliedTime != "",
			"applied_at":  appliedTime,
			"description": getMigrationDescription(migration.Name),
		})
	}

	return status, nil
}

// Helper functions

func createMigrationsTable() error {
	query := `
		CREATE TABLE IF NOT EXISTS migrations (
			version INTEGER PRIMARY KEY,
			name VARCHAR(255) NOT NULL,
			applied_at TIMESTAMPTZ DEFAULT NOW()
		)
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := Pool.Exec(ctx, query)
	return err
}

type appliedMigration struct {
	Version   int
	Name      string
	AppliedAt time.Time
}

func getAppliedMigrations() ([]appliedMigration, error) {
	query := `SELECT version, name, applied_at FROM migrations ORDER BY version`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := Pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var migrations []appliedMigration
	for rows.Next() {
		var m appliedMigration
		if err := rows.Scan(&m.Version, &m.Name, &m.AppliedAt); err != nil {
			return nil, err
		}
		migrations = append(migrations, m)
	}

	return migrations, nil
}

func loadMigrations(migrationsPath string) ([]Migration, error) {
	files, err := os.ReadDir(migrationsPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read migrations directory: %w", err)
	}

	migrationMap := make(map[int]*Migration)

	for _, file := range files {
		if file.IsDir() {
			continue
		}

		filename := file.Name()
		if !strings.HasSuffix(filename, ".up.sql") && !strings.HasSuffix(filename, ".down.sql") {
			continue
		}

		// Parse version and name from filename (e.g., "001_create_users_table.up.sql")
		parts := strings.Split(strings.TrimSuffix(filename, ".sql"), "_")
		if len(parts) < 3 {
			continue
		}

		version, err := strconv.Atoi(parts[0])
		if err != nil {
			continue
		}

		name := strings.Join(parts[1:], "_")
		name = strings.TrimSuffix(name, ".up")
		name = strings.TrimSuffix(name, ".down")

		if migrationMap[version] == nil {
			migrationMap[version] = &Migration{
				Version: version,
				Name:    name,
			}
		}

		// Read migration file content
		content, err := os.ReadFile(filepath.Join(migrationsPath, filename))
		if err != nil {
			return nil, fmt.Errorf("failed to read migration file %s: %w", filename, err)
		}

		if strings.HasSuffix(filename, ".up.sql") {
			migrationMap[version].Up = string(content)
		} else {
			migrationMap[version].Down = string(content)
		}
	}

	// Convert map to sorted slice
	var migrations []Migration
	for version := range migrationMap {
		migrations = append(migrations, *migrationMap[version])
	}

	sort.Slice(migrations, func(i, j int) bool {
		return migrations[i].Version < migrations[j].Version
	})

	return migrations, nil
}

func getPendingMigrations(all []Migration, applied []appliedMigration) []Migration {
	appliedMap := make(map[int]bool)
	for _, m := range applied {
		appliedMap[m.Version] = true
	}

	var pending []Migration
	for _, migration := range all {
		if !appliedMap[migration.Version] {
			pending = append(pending, migration)
		}
	}

	return pending
}

func getLatestVersion(applied []appliedMigration) int {
	if len(applied) == 0 {
		return 0
	}
	return applied[len(applied)-1].Version
}

func applyMigration(migration Migration) error {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Start transaction
	tx, err := Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	// Execute migration
	if _, err := tx.Exec(ctx, migration.Up); err != nil {
		return fmt.Errorf("failed to execute migration: %w", err)
	}

	// Record migration
	_, err = tx.Exec(ctx, "INSERT INTO migrations (version, name) VALUES ($1, $2)", migration.Version, migration.Name)
	if err != nil {
		return fmt.Errorf("failed to record migration: %w", err)
	}

	// Commit transaction
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit migration: %w", err)
	}

	return nil
}

func getMigrationDescription(name string) string {
	descriptions := map[string]string{
		"create_users_table":    "Create users table with authentication fields",
		"create_habits_table":   "Create habits table with frequency JSONB",
		"create_checkins_table": "Create checkins table with unique constraints",
	}
	return descriptions[name]
}
