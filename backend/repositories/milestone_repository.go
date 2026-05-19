package repositories

import (
	"context"
	"time"

	"cadence/db"
)

var MilestoneThresholds = []int{7, 30, 100, 365}

type MilestoneRepository struct{}

func NewMilestoneRepository() *MilestoneRepository {
	return &MilestoneRepository{}
}

// CountCheckins returns the total checkin count for a habit+user.
func (r *MilestoneRepository) CountCheckins(userID, habitID string) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var count int
	err := db.Pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM checkins WHERE user_id = $1 AND habit_id = $2`,
		userID, habitID,
	).Scan(&count)
	return count, err
}

// RecordIfNew inserts a milestone row if it doesn't exist yet. Returns the
// milestone value that was newly recorded, or 0 if nothing new was hit.
func (r *MilestoneRepository) RecordIfNew(userID, habitID string, count int) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	for _, threshold := range MilestoneThresholds {
		if count == threshold {
			_, err := db.Pool.Exec(ctx,
				`INSERT INTO milestones (user_id, habit_id, milestone_value)
				 VALUES ($1, $2, $3)
				 ON CONFLICT (user_id, habit_id, milestone_value) DO NOTHING`,
				userID, habitID, threshold,
			)
			if err != nil {
				return 0, err
			}
			return threshold, nil
		}
	}
	return 0, nil
}
