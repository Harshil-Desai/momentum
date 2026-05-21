package evaluators

import (
	"context"

	"cadence/db"
	"cadence/models"
)

type NightOwl struct{}

func (e *NightOwl) AchievementID() string { return "night_owl" }
func (e *NightOwl) TargetValue() int      { return 10 }

func (e *NightOwl) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	// Count distinct days where a checkin was created at or after 10PM UTC.
	var count int
	err := db.Pool.QueryRow(ctx, `
		SELECT COUNT(DISTINCT DATE(created_at))
		FROM checkins
		WHERE user_id = $1
		  AND EXTRACT(HOUR FROM created_at AT TIME ZONE 'UTC') >= 22
	`, userID).Scan(&count)
	if err != nil {
		return 0, false, err
	}
	progress := min(count, 10)
	return progress, count >= 10, nil
}
