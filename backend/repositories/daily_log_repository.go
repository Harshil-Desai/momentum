package repositories

import (
	"context"
	"errors"
	"time"

	"momentum/db"
	"momentum/models"

	"github.com/jackc/pgx/v5"
)

type DailyLogRepository struct{}

func NewDailyLogRepository() *DailyLogRepository {
	return &DailyLogRepository{}
}

// Upsert inserts or updates the daily log for a user on a given date.
func (r *DailyLogRepository) Upsert(log *models.DailyLog) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err := db.Pool.QueryRow(ctx,
		`INSERT INTO daily_logs (user_id, date, mood, energy)
		 VALUES ($1, $2, $3, $4)
		 ON CONFLICT (user_id, date) DO UPDATE
		   SET mood = EXCLUDED.mood,
		       energy = EXCLUDED.energy,
		       updated_at = NOW()
		 RETURNING id, created_at, updated_at`,
		log.UserID, log.Date, log.Mood, log.Energy,
	).Scan(&log.ID, &log.CreatedAt, &log.UpdatedAt)
	return err
}

// FindByDate returns the log for a specific date, or nil if none exists.
func (r *DailyLogRepository) FindByDate(userID string, date time.Time) (*models.DailyLog, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var log models.DailyLog
	err := db.Pool.QueryRow(ctx,
		`SELECT id, user_id, date, mood, energy, created_at, updated_at
		 FROM daily_logs WHERE user_id = $1 AND date = $2`,
		userID, date,
	).Scan(&log.ID, &log.UserID, &log.Date, &log.Mood, &log.Energy, &log.CreatedAt, &log.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &log, err
}

// EnergyCorrelation returns average completion rate per energy level for a user.
func (r *DailyLogRepository) EnergyCorrelation(userID string) ([]models.EnergyCorrelationPoint, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx,
		`SELECT dl.energy,
		        COUNT(DISTINCT c.habit_id || c.date::text)::float /
		        NULLIF(COUNT(DISTINCT h.id || dl.date::text), 0) AS completion_rate
		 FROM daily_logs dl
		 JOIN habits h ON h.user_id = dl.user_id AND h.archived = false
		 LEFT JOIN checkins c ON c.user_id = dl.user_id AND c.date = dl.date
		 WHERE dl.user_id = $1 AND dl.energy IS NOT NULL
		 GROUP BY dl.energy
		 ORDER BY dl.energy`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var points []models.EnergyCorrelationPoint
	for rows.Next() {
		var p models.EnergyCorrelationPoint
		if err := rows.Scan(&p.EnergyLevel, &p.CompletionRate); err != nil {
			return nil, err
		}
		points = append(points, p)
	}
	return points, rows.Err()
}
