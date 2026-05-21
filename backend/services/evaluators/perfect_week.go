package evaluators

import (
	"context"

	"cadence/db"
	"cadence/models"
)

type PerfectWeek struct{}

func (e *PerfectWeek) AchievementID() string { return "perfect_week" }
func (e *PerfectWeek) TargetValue() int      { return 7 }

func (e *PerfectWeek) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	// Count how many of the last 7 days have ALL active habits checked in.
	// We compute gaps: required (date × habit) minus completed. If gaps == 0, earned.
	// progress = number of days in the window where every habit was done.
	var gaps int
	err := db.Pool.QueryRow(ctx, `
		WITH date_series AS (
			SELECT generate_series(
				CURRENT_DATE - INTERVAL '6 days',
				CURRENT_DATE,
				INTERVAL '1 day'
			)::date AS d
		),
		active_habits AS (
			SELECT id FROM habits WHERE user_id = $1 AND archived = false
		),
		required AS (
			SELECT d, h.id AS habit_id FROM date_series CROSS JOIN active_habits h
		),
		completed AS (
			SELECT date, habit_id FROM checkins
			WHERE user_id = $1 AND date >= CURRENT_DATE - INTERVAL '6 days'
		)
		SELECT COUNT(*) FROM required r
		LEFT JOIN completed c ON r.d = c.date AND r.habit_id = c.habit_id
		WHERE c.habit_id IS NULL
	`, userID).Scan(&gaps)
	if err != nil {
		return 0, false, err
	}

	// Count days with full completion for progress display.
	var completeDays int
	err = db.Pool.QueryRow(ctx, `
		WITH date_series AS (
			SELECT generate_series(
				CURRENT_DATE - INTERVAL '6 days',
				CURRENT_DATE,
				INTERVAL '1 day'
			)::date AS d
		),
		active_habits AS (
			SELECT id FROM habits WHERE user_id = $1 AND archived = false
		),
		habit_count AS (SELECT COUNT(*) AS total FROM active_habits),
		daily_done AS (
			SELECT c.date, COUNT(*) AS done
			FROM checkins c
			JOIN active_habits h ON c.habit_id = h.id
			WHERE c.user_id = $1 AND c.date >= CURRENT_DATE - INTERVAL '6 days'
			GROUP BY c.date
		)
		SELECT COUNT(*) FROM daily_done, habit_count WHERE done >= total
	`, userID).Scan(&completeDays)
	if err != nil {
		return 0, false, err
	}

	return completeDays, gaps == 0, nil
}
