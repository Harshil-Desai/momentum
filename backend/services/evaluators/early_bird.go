package evaluators

import (
	"context"

	"cadence/db"
	"cadence/models"
)

type EarlyBird struct{}

func (e *EarlyBird) AchievementID() string { return "early_bird" }
func (e *EarlyBird) TargetValue() int      { return 10 }

func (e *EarlyBird) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	// Count distinct days where a checkin was created before 8AM UTC.
	var count int
	err := db.Pool.QueryRow(ctx, `
		SELECT COUNT(DISTINCT DATE(created_at))
		FROM checkins
		WHERE user_id = $1
		  AND EXTRACT(HOUR FROM created_at AT TIME ZONE 'UTC') < 8
	`, userID).Scan(&count)
	if err != nil {
		return 0, false, err
	}
	progress := min(count, 10)
	return progress, count >= 10, nil
}
