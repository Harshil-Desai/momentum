package repositories

import (
	"context"
	"time"

	"cadence/db"
)

type DayCount struct {
	DayOfWeek int `json:"day_of_week"` // 0=Sunday … 6=Saturday
	Count     int `json:"count"`
}

type HabitStreakSummary struct {
	HabitID   string `json:"habit_id"`
	HabitName string `json:"habit_name"`
	Current   int    `json:"current_streak"`
	Best      int    `json:"best_streak"`
}

type HabitCorrelation struct {
	HabitAID   string  `json:"habit_a_id"`
	HabitAName string  `json:"habit_a_name"`
	HabitBID   string  `json:"habit_b_id"`
	HabitBName string  `json:"habit_b_name"`
	Percentage float64 `json:"percentage"` // 0–100
}

type HabitForecast struct {
	HabitID        string  `json:"habit_id"`
	HabitName      string  `json:"habit_name"`
	DayOfWeek      int     `json:"day_of_week"`      // 0=Sun … 6=Sat
	CompletionRate float64 `json:"completion_rate"`  // 0.0–1.0
	SampleWeeks    int     `json:"sample_weeks"`
	NudgeCopy      string  `json:"nudge_copy"`
}

type HabitMonthlySummary struct {
	HabitID    string  `json:"habit_id"`
	HabitName  string  `json:"habit_name"`
	Checkins   int     `json:"checkins"`
	RatePct    float64 `json:"rate_pct"`
}

type WeekSummary struct {
	WeekStart string `json:"week_start"` // "YYYY-MM-DD"
	Checkins  int    `json:"checkins"`
}

type MonthlyReview struct {
	Month          string                `json:"month"`           // "2026-04"
	TotalCheckins  int                   `json:"total_checkins"`
	Wins           []HabitMonthlySummary `json:"wins"`
	DroppedOff     []HabitMonthlySummary `json:"dropped_off"`
	Held           []HabitMonthlySummary `json:"held"`
	LowestWeek     WeekSummary           `json:"lowest_week"`
}

type InsightsRepository struct{}

func NewInsightsRepository() *InsightsRepository {
	return &InsightsRepository{}
}

func (r *InsightsRepository) TotalCheckins(userID string) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var n int
	err := db.Pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM checkins WHERE user_id = $1`, userID,
	).Scan(&n)
	return n, err
}

// MaxHabitCheckins returns the highest check-in count for any single habit belonging to the user.
func (r *InsightsRepository) MaxHabitCheckins(userID string) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var n int
	err := db.Pool.QueryRow(ctx,
		`SELECT COALESCE(MAX(cnt), 0) FROM (
			SELECT COUNT(*) AS cnt FROM checkins WHERE user_id = $1 GROUP BY habit_id
		) sub`, userID,
	).Scan(&n)
	return n, err
}

// DayOfWeekCounts returns checkin counts grouped by day-of-week (0=Sun).
func (r *InsightsRepository) DayOfWeekCounts(userID string) ([]DayCount, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx, `
		SELECT EXTRACT(DOW FROM date)::int AS dow, COUNT(*)::int AS cnt
		FROM checkins
		WHERE user_id = $1
		GROUP BY dow
		ORDER BY dow
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []DayCount
	for rows.Next() {
		var dc DayCount
		if err := rows.Scan(&dc.DayOfWeek, &dc.Count); err != nil {
			return nil, err
		}
		result = append(result, dc)
	}
	return result, rows.Err()
}

// MonthlyRate returns completed checkins and possible checkins for the current calendar month.
func (r *InsightsRepository) MonthlyRate(userID string) (completed, possible int, err error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	now := time.Now().UTC()
	firstOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	daysElapsed := now.Day()

	// Active habits × days elapsed in month
	var activeHabits int
	err = db.Pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM habits WHERE user_id = $1 AND archived = false`, userID,
	).Scan(&activeHabits)
	if err != nil {
		return 0, 0, err
	}
	possible = activeHabits * daysElapsed

	err = db.Pool.QueryRow(ctx, `
		SELECT COUNT(DISTINCT (habit_id, date))
		FROM checkins
		WHERE user_id = $1 AND date >= $2
	`, userID, firstOfMonth).Scan(&completed)
	return completed, possible, err
}

// HabitStreaks returns current + best streak for every active habit.
func (r *InsightsRepository) HabitStreaks(userID string) ([]HabitStreakSummary, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx,
		`SELECT id, name FROM habits WHERE user_id = $1 AND archived = false ORDER BY created_at ASC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	type habitRow struct {
		id   string
		name string
	}
	var habits []habitRow
	for rows.Next() {
		var h habitRow
		if err := rows.Scan(&h.id, &h.name); err != nil {
			return nil, err
		}
		habits = append(habits, h)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	var summaries []HabitStreakSummary
	for _, h := range habits {
		var current, best int
		ctx2, cancel2 := context.WithTimeout(context.Background(), 5*time.Second)
		err1 := db.Pool.QueryRow(ctx2, `SELECT get_habit_streak($1::uuid, $2::uuid)`, userID, h.id).Scan(&current)
		err2 := db.Pool.QueryRow(ctx2, `SELECT get_habit_best_streak($1::uuid, $2::uuid)`, userID, h.id).Scan(&best)
		cancel2()
		if err1 != nil || err2 != nil {
			continue
		}
		summaries = append(summaries, HabitStreakSummary{
			HabitID:   h.id,
			HabitName: h.name,
			Current:   current,
			Best:      best,
		})
	}
	return summaries, nil
}

// GetHabitCorrelations returns pairs of habits that are completed together >= 20% of the time
// within the last lookbackDays days.
func (r *InsightsRepository) GetHabitCorrelations(userID string, lookbackDays int) ([]HabitCorrelation, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx, `
		SELECT a.habit_id, ha.name, b.habit_id, hb.name,
		       ROUND(COUNT(*)::numeric / NULLIF(base.total, 0) * 100, 1) AS percentage
		FROM checkins a
		JOIN checkins b
		  ON a.user_id = b.user_id AND a.date = b.date AND a.habit_id < b.habit_id
		JOIN habits ha ON ha.id = a.habit_id
		JOIN habits hb ON hb.id = b.habit_id
		JOIN (
		  SELECT habit_id, COUNT(*) AS total
		  FROM checkins
		  WHERE user_id = $1 AND date >= CURRENT_DATE - $2::int
		  GROUP BY habit_id
		) base ON base.habit_id = a.habit_id
		WHERE a.user_id = $1 AND a.date >= CURRENT_DATE - $2::int
		GROUP BY a.habit_id, ha.name, b.habit_id, hb.name, base.total
		HAVING ROUND(COUNT(*)::numeric / NULLIF(base.total, 0) * 100, 1) >= 20
		ORDER BY percentage DESC
		LIMIT 20
	`, userID, lookbackDays)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []HabitCorrelation
	for rows.Next() {
		var c HabitCorrelation
		if err := rows.Scan(&c.HabitAID, &c.HabitAName, &c.HabitBID, &c.HabitBName, &c.Percentage); err != nil {
			return nil, err
		}
		result = append(result, c)
	}
	return result, rows.Err()
}

// GetDayOfWeekRates returns per-habit completion rates broken down by day of week
// over the last windowWeeks weeks.
func (r *InsightsRepository) GetDayOfWeekRates(userID string, windowWeeks int) ([]HabitForecast, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx, `
		WITH dates AS (
		  SELECT generate_series(
		    CURRENT_DATE - ($2::int * 7),
		    CURRENT_DATE,
		    '1 day'::interval
		  )::date AS d
		),
		habit_dates AS (
		  SELECT h.id AS habit_id, h.name, d.d, EXTRACT(DOW FROM d.d)::int AS dow
		  FROM habits h CROSS JOIN dates d
		  WHERE h.user_id = $1 AND h.archived = false
		    AND h.created_at::date <= d.d
		),
		checkin_flags AS (
		  SELECT hd.habit_id, hd.name, hd.dow,
		         COUNT(c.date) AS done, COUNT(*) AS total
		  FROM habit_dates hd
		  LEFT JOIN checkins c
		    ON c.habit_id = hd.habit_id AND c.user_id = $1 AND c.date = hd.d
		  GROUP BY hd.habit_id, hd.name, hd.dow
		)
		SELECT habit_id, name, dow,
		       ROUND(done::numeric / NULLIF(total, 0), 4) AS rate,
		       total AS sample_weeks
		FROM checkin_flags
		WHERE total > 0
		ORDER BY habit_id, dow
	`, userID, windowWeeks)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []HabitForecast
	for rows.Next() {
		var f HabitForecast
		if err := rows.Scan(&f.HabitID, &f.HabitName, &f.DayOfWeek, &f.CompletionRate, &f.SampleWeeks); err != nil {
			return nil, err
		}
		result = append(result, f)
	}
	return result, rows.Err()
}

// GetMonthlyReviewData returns aggregated checkin data for a specific year/month.
func (r *InsightsRepository) GetMonthlyReviewData(userID string, year, month int) (*MonthlyReview, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	monthStr := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC).Format("2006-01")
	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastDay := firstDay.AddDate(0, 1, -1)
	daysInMonth := lastDay.Day()

	// Total checkins for the month
	var totalCheckins int
	err := db.Pool.QueryRow(ctx, `
		SELECT COUNT(DISTINCT (habit_id, date))
		FROM checkins
		WHERE user_id = $1 AND date >= $2 AND date <= $3
	`, userID, firstDay, lastDay).Scan(&totalCheckins)
	if err != nil {
		return nil, err
	}

	// Per-habit checkins and rate
	rows, err := db.Pool.Query(ctx, `
		SELECT h.id, h.name, COUNT(c.date) AS checkins
		FROM habits h
		LEFT JOIN checkins c
		  ON c.habit_id = h.id AND c.user_id = $1 AND c.date >= $2 AND c.date <= $3
		WHERE h.user_id = $1 AND h.archived = false
		GROUP BY h.id, h.name
		ORDER BY checkins DESC
	`, userID, firstDay, lastDay)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	type habitCheckin struct {
		id       string
		name     string
		checkins int
	}
	var habits []habitCheckin
	for rows.Next() {
		var h habitCheckin
		if err := rows.Scan(&h.id, &h.name, &h.checkins); err != nil {
			return nil, err
		}
		habits = append(habits, h)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Weekly breakdown to find lowest week
	weekRows, err := db.Pool.Query(ctx, `
		SELECT DATE_TRUNC('week', date)::date AS week_start, COUNT(*) AS cnt
		FROM checkins
		WHERE user_id = $1 AND date >= $2 AND date <= $3
		GROUP BY week_start
		ORDER BY week_start
	`, userID, firstDay, lastDay)
	if err != nil {
		return nil, err
	}
	defer weekRows.Close()

	lowest := WeekSummary{WeekStart: firstDay.Format("2006-01-02"), Checkins: daysInMonth * len(habits)}
	for weekRows.Next() {
		var ws WeekSummary
		var t time.Time
		if err := weekRows.Scan(&t, &ws.Checkins); err != nil {
			return nil, err
		}
		ws.WeekStart = t.Format("2006-01-02")
		if ws.Checkins < lowest.Checkins {
			lowest = ws
		}
	}
	if err := weekRows.Err(); err != nil {
		return nil, err
	}

	// Classify habits
	review := &MonthlyReview{
		Month:         monthStr,
		TotalCheckins: totalCheckins,
		LowestWeek:    lowest,
	}
	for _, h := range habits {
		rate := 0.0
		if daysInMonth > 0 {
			rate = float64(h.checkins) / float64(daysInMonth) * 100
		}
		summary := HabitMonthlySummary{
			HabitID:   h.id,
			HabitName: h.name,
			Checkins:  h.checkins,
			RatePct:   rate,
		}
		switch {
		case rate >= 80:
			review.Wins = append(review.Wins, summary)
		case rate < 30:
			review.DroppedOff = append(review.DroppedOff, summary)
		default:
			review.Held = append(review.Held, summary)
		}
	}
	return review, nil
}
