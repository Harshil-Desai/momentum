package evaluators

import (
	"context"

	"cadence/models"
)

// ThePhilosopher is a no-op stub until the reflections feature ships.
type ThePhilosopher struct{}

func (e *ThePhilosopher) AchievementID() string { return "the_philosopher" }
func (e *ThePhilosopher) TargetValue() int      { return 10 }

func (e *ThePhilosopher) Evaluate(_ context.Context, _ string, _ models.AchievementEvent) (int, bool, error) {
	return 0, false, nil
}
