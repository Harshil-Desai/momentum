package main

import (
	"flag"
	"fmt"
	"log"
	"cadence/db"
	"os"
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage: %s [command]\n", os.Args[0])
		fmt.Fprintln(flag.CommandLine.Output(), "Commands:")
		fmt.Fprintln(flag.CommandLine.Output(), "  up        Apply all pending migrations")
		fmt.Fprintln(flag.CommandLine.Output(), "  down      Rollback the last migration")
		fmt.Fprintln(flag.CommandLine.Output(), "  status    Show migration status")
		fmt.Fprintln(flag.CommandLine.Output(), "  version   Show current migration version")
	}

	if len(os.Args) < 2 {
		flag.Usage()
		os.Exit(1)
	}

	command := os.Args[1]
	migrationsPath := "./migrations/"

	// Initialize database
	// cfg := config.LoadConfig()
	dbConfig := db.DefaultConfig()
	if err := db.InitDB(dbConfig); err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.CloseDB()

	switch command {
	case "up":
		result, err := db.RunMigrations(migrationsPath)
		if err != nil {
			log.Fatal("Migration failed:", err)
		}
		fmt.Printf("Successfully applied %d migrations\n", result.TotalApplied)
		fmt.Printf("Current version: %d\n", result.LastVersion)

	case "down":
		if err := db.RollbackMigration(); err != nil {
			log.Fatal("Rollback failed:", err)
		}
		fmt.Println("Successfully rolled back last migration")

	case "status":
		status, err := db.GetMigrationStatus(migrationsPath)
		if err != nil {
			log.Fatal("Failed to get migration status:", err)
		}

		fmt.Println("Migration Status:")
		fmt.Println("Version | Name                | Applied | Description")
		fmt.Println("--------|---------------------|---------|------------")
		for _, s := range status {
			applied := "❌"
			if s["applied"].(bool) {
				applied = "✅"
			}
			fmt.Printf("%7d | %-19s | %s | %s\n",
				s["version"], s["name"], applied, s["description"])
		}

	case "version":
		status, err := db.GetMigrationStatus(migrationsPath)
		if err != nil {
			log.Fatal("Failed to get migration status:", err)
		}

		var latestVersion int
		for _, s := range status {
			if s["applied"].(bool) {
				latestVersion = s["version"].(int)
			}
		}
		fmt.Printf("Current migration version: %d\n", latestVersion)

	default:
		fmt.Printf("Unknown command: %s\n\n", command)
		flag.Usage()
		os.Exit(1)
	}
}