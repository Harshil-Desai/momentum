package evaluators

import (
	"context"

	"cadence/models"
)

type InTheFlow struct{}

func (e *InTheFlow) AchievementID() string { return "in_the_flow" }
func (e *InTheFlow) TargetValue() int      { return 30 }

func (e *InTheFlow) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	streak, err := maxOverallStreak(ctx, userID)
	if err != nil {
		return 0, false, err
	}
	progress := min(streak, 30)
	return progress, streak >= 30, nil
}
