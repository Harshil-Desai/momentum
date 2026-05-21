package evaluators

import (
	"context"

	"cadence/models"
)

type WeekOne struct{}

func (e *WeekOne) AchievementID() string { return "week_one" }
func (e *WeekOne) TargetValue() int      { return 7 }

func (e *WeekOne) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	streak, err := maxOverallStreak(ctx, userID)
	if err != nil {
		return 0, false, err
	}
	progress := min(streak, 7)
	return progress, streak >= 7, nil
}
