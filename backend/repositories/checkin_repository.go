package repositories

import (
	"context"
	"errors"
	"time"

	"cadence/db"
	"cadence/models"

	"github.com/jackc/pgx/v5"
)

type CheckinRepository struct{}

func NewCheckinRepository() *CheckinRepository {
	return &CheckinRepository{}
}

// Create inserts a checkin. Idempotent: duplicate (user, habit, date) returns existing row.
// Returns true if a new row was created, false if it already existed.
func (r *CheckinRepository) Create(checkin *models.Checkin) (bool, error) {
	insertQuery := `
		INSERT INTO checkins (user_id, habit_id, date)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id, habit_id, date) DO NOTHING
		RETURNING id, created_at
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err := db.Pool.QueryRow(ctx, insertQuery,
		checkin.UserID, checkin.HabitID, checkin.Date,
	).Scan(&checkin.ID, &checkin.CreatedAt)

	if err != nil {
		// pgx returns ErrNoRows when ON CONFLICT DO NOTHING fires (no row returned)
		// In that case, fetch the existing row.
		if errors.Is(err, pgx.ErrNoRows) {
			selectQuery := `SELECT id, created_at FROM checkins WHERE user_id = $1 AND habit_id = $2 AND date = $3`
			err2 := db.Pool.QueryRow(ctx, selectQuery,
				checkin.UserID, checkin.HabitID, checkin.Date,
			).Scan(&checkin.ID, &checkin.CreatedAt)
			return false, err2 // false = already existed
		}
		return false, err
	}
	return true, nil // true = newly created
}

// GetHistory returns all checkin dates for a habit plus the lifetime count.
func (r *CheckinRepository) GetHistory(userID, habitID string) ([]time.Time, int, error) {
	query := `
		SELECT date
		FROM checkins
		WHERE user_id = $1 AND habit_id = $2
		ORDER BY date DESC
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx, query, userID, habitID)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var dates []time.Time
	for rows.Next() {
		var d time.Time
		if err := rows.Scan(&d); err != nil {
			return nil, 0, err
		}
		dates = append(dates, d)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, err
	}
	return dates, len(dates), nil
}

// DeleteToday removes the checkin for today for a given user+habit. No-op if none exists.
func (r *CheckinRepository) DeleteToday(userID, habitID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	today := time.Now().UTC().Truncate(24 * time.Hour)
	_, err := db.Pool.Exec(ctx,
		`DELETE FROM checkins WHERE user_id = $1 AND habit_id = $2 AND date = $3`,
		userID, habitID, today,
	)
	return err
}

// GetCurrentStreak returns the current streak using the SQL utility function.
func (r *CheckinRepository) GetCurrentStreak(userID, habitID string) (int, error) {
	query := `SELECT get_habit_streak($1::uuid, $2::uuid)`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var streak int
	err := db.Pool.QueryRow(ctx, query, userID, habitID).Scan(&streak)
	return streak, err
}
