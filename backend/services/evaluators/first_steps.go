package evaluators

import (
	"context"

	"cadence/db"
	"cadence/models"
)

type FirstSteps struct{}

func (e *FirstSteps) AchievementID() string { return "first_steps" }
func (e *FirstSteps) TargetValue() int      { return 1 }

func (e *FirstSteps) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	var count int
	err := db.Pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM checkins WHERE user_id = $1`, userID,
	).Scan(&count)
	if err != nil {
		return 0, false, err
	}
	if count > 1 {
		count = 1
	}
	return count, count >= 1, nil
}
