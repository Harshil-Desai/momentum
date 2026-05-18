package repositories

import (
	"context"
	"time"

	"momentum/db"
	"momentum/models"
)

type SubtaskRepository struct{}

func NewSubtaskRepository() *SubtaskRepository { return &SubtaskRepository{} }

// ReplaceAll deletes all subtasks for a habit and inserts the new set.
func (r *SubtaskRepository) ReplaceAll(habitID string, reqs []models.SubtaskRequest) ([]models.HabitSubtask, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := db.Pool.Exec(ctx, `DELETE FROM habit_subtasks WHERE habit_id = $1`, habitID)
	if err != nil {
		return nil, err
	}

	var subtasks []models.HabitSubtask
	for _, req := range reqs {
		var s models.HabitSubtask
		err := db.Pool.QueryRow(ctx,
			`INSERT INTO habit_subtasks (habit_id, label, sort_order)
			 VALUES ($1, $2, $3)
			 RETURNING id, habit_id, label, sort_order, created_at`,
			habitID, req.Label, req.SortOrder,
		).Scan(&s.ID, &s.HabitID, &s.Label, &s.SortOrder, &s.CreatedAt)
		if err != nil {
			return nil, err
		}
		subtasks = append(subtasks, s)
	}
	return subtasks, nil
}

// ListByHabit returns all subtasks for a habit ordered by sort_order.
func (r *SubtaskRepository) ListByHabit(habitID string) ([]models.HabitSubtask, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx,
		`SELECT id, habit_id, label, sort_order, created_at
		 FROM habit_subtasks WHERE habit_id = $1 ORDER BY sort_order`,
		habitID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subtasks []models.HabitSubtask
	for rows.Next() {
		var s models.HabitSubtask
		if err := rows.Scan(&s.ID, &s.HabitID, &s.Label, &s.SortOrder, &s.CreatedAt); err != nil {
			return nil, err
		}
		subtasks = append(subtasks, s)
	}
	return subtasks, rows.Err()
}

// UpsertCheckinSubtasks updates the completed_subtask_ids on a checkin row.
// It creates the checkin row if it doesn't exist yet (partial completion).
func (r *SubtaskRepository) UpsertCheckinSubtasks(userID, habitID string, date time.Time, completedIDs []string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Convert []string to a format pgx accepts for UUID[]
	ids := make([]interface{}, len(completedIDs))
	for i, id := range completedIDs {
		ids[i] = id
	}

	_, err := db.Pool.Exec(ctx,
		`INSERT INTO checkins (user_id, habit_id, date, completed_subtask_ids)
		 VALUES ($1, $2, $3, $4::uuid[])
		 ON CONFLICT (user_id, habit_id, date)
		 DO UPDATE SET completed_subtask_ids = EXCLUDED.completed_subtask_ids`,
		userID, habitID, date, completedIDs,
	)
	return err
}
