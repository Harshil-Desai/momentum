package evaluators

import (
	"context"

	"cadence/models"
)

type TwoWeeksStrong struct{}

func (e *TwoWeeksStrong) AchievementID() string { return "two_weeks_strong" }
func (e *TwoWeeksStrong) TargetValue() int      { return 14 }

func (e *TwoWeeksStrong) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	streak, err := maxOverallStreak(ctx, userID)
	if err != nil {
		return 0, false, err
	}
	progress := min(streak, 14)
	return progress, streak >= 14, nil
}
