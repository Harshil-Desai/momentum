package repositories

import (
	"context"
	"errors"
	"time"

	"cadence/db"
)

var ErrGraceDayAlreadyUsed = errors.New("grace day already used this month")

type GraceDayRepository struct{}

func NewGraceDayRepository() *GraceDayRepository {
	return &GraceDayRepository{}
}

// UsedThisMonth returns true if the user has already claimed a grace day for
// this habit in the current calendar month.
func (r *GraceDayRepository) UsedThisMonth(userID, habitID string) (bool, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var count int
	err := db.Pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM grace_days
		 WHERE user_id = $1 AND habit_id = $2
		   AND date_trunc('month', date) = date_trunc('month', CURRENT_DATE)`,
		userID, habitID,
	).Scan(&count)
	return count > 0, err
}

// Claim inserts a grace day for the given date. Returns ErrGraceDayAlreadyUsed
// if one has already been claimed this calendar month.
func (r *GraceDayRepository) Claim(userID, habitID string, date time.Time) error {
	used, err := r.UsedThisMonth(userID, habitID)
	if err != nil {
		return err
	}
	if used {
		return ErrGraceDayAlreadyUsed
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err = db.Pool.Exec(ctx,
		`INSERT INTO grace_days (user_id, habit_id, date) VALUES ($1, $2, $3)
		 ON CONFLICT (user_id, habit_id, date) DO NOTHING`,
		userID, habitID, date,
	)
	return err
}
