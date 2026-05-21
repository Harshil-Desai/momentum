package evaluators

import (
	"context"
	"time"

	"cadence/db"
	"cadence/models"
)

// Evaluator is implemented by each achievement.
type Evaluator interface {
	AchievementID() string
	TargetValue() int
	Evaluate(ctx context.Context, userID string, event models.AchievementEvent) (progress int, earned bool, err error)
}

// maxOverallStreak returns the longest streak across all habits for a user,
// using the per-day distinct date approach (a day counts if any habit was checked in).
func maxOverallStreak(ctx context.Context, userID string) (int, error) {
	var streak int
	err := db.Pool.QueryRow(ctx, `
		WITH daily AS (
			SELECT DISTINCT date FROM checkins WHERE user_id = $1
		),
		groups AS (
			SELECT date,
			       (date - (ROW_NUMBER() OVER (ORDER BY date) * INTERVAL '1 day')::date) AS grp
			FROM daily
		)
		SELECT COALESCE(MAX(cnt), 0)
		FROM (SELECT COUNT(*) AS cnt FROM groups GROUP BY grp) t
	`, userID).Scan(&streak)
	return streak, err
}

// allStreaks returns all completed streak windows (start, end, length) for a user,
// ordered by end date descending.
type streakWindow struct {
	Start time.Time
	End   time.Time
	Len   int
}

func allStreakWindows(ctx context.Context, userID string) ([]streakWindow, error) {
	rows, err := db.Pool.Query(ctx, `
		WITH daily AS (
			SELECT DISTINCT date FROM checkins WHERE user_id = $1
		),
		groups AS (
			SELECT date,
			       (date - (ROW_NUMBER() OVER (ORDER BY date) * INTERVAL '1 day')::date) AS grp
			FROM daily
		)
		SELECT MIN(date), MAX(date), COUNT(*) AS len
		FROM groups
		GROUP BY grp
		ORDER BY MAX(date) DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var windows []streakWindow
	for rows.Next() {
		var w streakWindow
		if err := rows.Scan(&w.Start, &w.End, &w.Len); err != nil {
			return nil, err
		}
		windows = append(windows, w)
	}
	return windows, rows.Err()
}
