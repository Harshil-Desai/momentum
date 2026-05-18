package models

import "time"

type HabitSubtask struct {
	ID        string    `json:"id"`
	HabitID   string    `json:"habit_id"`
	Label     string    `json:"label"`
	SortOrder int       `json:"sort_order"`
	CreatedAt time.Time `json:"created_at"`
}

type SubtaskRequest struct {
	ID    string `json:"id,omitempty"` // empty on create
	Label string `json:"label" binding:"required"`
	SortOrder int `json:"sort_order"`
}

type SubtaskCheckinRequest struct {
	Date             string   `json:"date" binding:"required"`
	CompletedIDs     []string `json:"completed_ids"`
}
