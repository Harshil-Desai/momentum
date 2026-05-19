package repositories

import (
	"context"
	"encoding/json"
	"time"

	"cadence/db"
	"cadence/models"

	"github.com/jackc/pgx/v5"
)

type HabitRepository struct{}

func NewHabitRepository() *HabitRepository {
	return &HabitRepository{}
}

func (r *HabitRepository) Create(habit *models.Habit) error {
	query := `
		INSERT INTO habits (user_id, name, icon, color, frequency, note, two_minute_version, stack_after_habit_id, is_negative)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, created_at, updated_at
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	freqJSON, err := json.Marshal(habit.Frequency)
	if err != nil {
		return err
	}

	return db.Pool.QueryRow(ctx, query,
		habit.UserID, habit.Name, habit.Icon, habit.Color,
		freqJSON, habit.Note, habit.TwoMinuteVersion, habit.StackAfterHabitID, habit.IsNegative,
	).Scan(&habit.ID, &habit.CreatedAt, &habit.UpdatedAt)
}

func (r *HabitRepository) FindByID(id, userID string) (*models.Habit, error) {
	query := `
		SELECT id, user_id, name, icon, color, frequency, note, two_minute_version,
		       stack_after_habit_id, is_negative, archived, created_at, updated_at
		FROM habits
		WHERE id = $1 AND user_id = $2 AND archived = false
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var habit models.Habit
	var freqJSON []byte
	err := db.Pool.QueryRow(ctx, query, id, userID).Scan(
		&habit.ID, &habit.UserID, &habit.Name, &habit.Icon, &habit.Color,
		&freqJSON, &habit.Note, &habit.TwoMinuteVersion, &habit.StackAfterHabitID,
		&habit.IsNegative, &habit.Archived, &habit.CreatedAt, &habit.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if err := json.Unmarshal(freqJSON, &habit.Frequency); err != nil {
		return nil, err
	}
	return &habit, nil
}

func (r *HabitRepository) ListByUser(userID string) ([]*models.Habit, error) {
	query := `
		SELECT id, user_id, name, icon, color, frequency, note, two_minute_version,
		       stack_after_habit_id, is_negative, archived, created_at, updated_at
		FROM habits
		WHERE user_id = $1 AND archived = false
		ORDER BY created_at ASC
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var habits []*models.Habit
	for rows.Next() {
		var habit models.Habit
		var freqJSON []byte
		if err := rows.Scan(
			&habit.ID, &habit.UserID, &habit.Name, &habit.Icon, &habit.Color,
			&freqJSON, &habit.Note, &habit.TwoMinuteVersion, &habit.StackAfterHabitID,
			&habit.IsNegative, &habit.Archived, &habit.CreatedAt, &habit.UpdatedAt,
		); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(freqJSON, &habit.Frequency); err != nil {
			return nil, err
		}
		habits = append(habits, &habit)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return habits, nil
}

func (r *HabitRepository) Update(id, userID string, req models.HabitUpdateRequest) (*models.Habit, error) {
	query := `
		UPDATE habits
		SET name               = COALESCE($3, name),
		    icon               = CASE WHEN $4::boolean THEN $5 ELSE icon END,
		    color              = CASE WHEN $6::boolean THEN $7 ELSE color END,
		    note               = CASE WHEN $8::boolean THEN $9 ELSE note END,
		    two_minute_version = CASE WHEN $10::boolean THEN $11 ELSE two_minute_version END,
		    is_negative        = CASE WHEN $12::boolean THEN $13 ELSE is_negative END,
		    updated_at         = NOW()
		WHERE id = $1 AND user_id = $2 AND archived = false
		RETURNING id, user_id, name, icon, color, frequency, note, two_minute_version,
		          stack_after_habit_id, is_negative, archived, created_at, updated_at
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var habit models.Habit
	var freqJSON []byte
	err := db.Pool.QueryRow(ctx, query,
		id, userID,
		req.Name,
		req.Icon != nil, req.Icon,
		req.Color != nil, req.Color,
		req.Note != nil, req.Note,
		req.TwoMinuteVersion != nil, req.TwoMinuteVersion,
		req.IsNegative != nil, req.IsNegative,
	).Scan(
		&habit.ID, &habit.UserID, &habit.Name, &habit.Icon, &habit.Color,
		&freqJSON, &habit.Note, &habit.TwoMinuteVersion, &habit.StackAfterHabitID,
		&habit.IsNegative, &habit.Archived, &habit.CreatedAt, &habit.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if err := json.Unmarshal(freqJSON, &habit.Frequency); err != nil {
		return nil, err
	}
	return &habit, nil
}

func (r *HabitRepository) ListArchived(userID string) ([]*models.Habit, error) {
	query := `
		SELECT id, user_id, name, icon, color, frequency, note, two_minute_version,
		       stack_after_habit_id, is_negative, archived, created_at, updated_at
		FROM habits
		WHERE user_id = $1 AND archived = true
		ORDER BY updated_at DESC
	`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var habits []*models.Habit
	for rows.Next() {
		var habit models.Habit
		var freqJSON []byte
		if err := rows.Scan(
			&habit.ID, &habit.UserID, &habit.Name, &habit.Icon, &habit.Color,
			&freqJSON, &habit.Note, &habit.TwoMinuteVersion, &habit.StackAfterHabitID,
			&habit.IsNegative, &habit.Archived, &habit.CreatedAt, &habit.UpdatedAt,
		); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(freqJSON, &habit.Frequency); err != nil {
			return nil, err
		}
		habits = append(habits, &habit)
	}
	return habits, rows.Err()
}

func (r *HabitRepository) Archive(id, userID string) error {
	query := `UPDATE habits SET archived = true, updated_at = NOW() WHERE id = $1 AND user_id = $2`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := db.Pool.Exec(ctx, query, id, userID)
	return err
}
