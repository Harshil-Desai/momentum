package evaluators

import (
	"context"

	"cadence/models"
)

type HabitForged struct{}

func (e *HabitForged) AchievementID() string { return "habit_forged" }
func (e *HabitForged) TargetValue() int      { return 21 }

func (e *HabitForged) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	streak, err := maxOverallStreak(ctx, userID)
	if err != nil {
		return 0, false, err
	}
	progress := min(streak, 21)
	return progress, streak >= 21, nil
}
