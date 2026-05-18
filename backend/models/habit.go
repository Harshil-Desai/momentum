package models

import (
	"time"
)

// Habit represents a habit in the system
type Habit struct {
	ID                string     `json:"id" db:"id"`
	UserID            string     `json:"user_id" db:"user_id"`
	Name              string     `json:"name" db:"name"`
	Icon              *string    `json:"icon,omitempty" db:"icon"`
	Color             *string    `json:"color,omitempty" db:"color"`
	Frequency         Frequency  `json:"frequency" db:"frequency"`
	Note              *string    `json:"note,omitempty" db:"note"`
	TwoMinuteVersion  *string    `json:"two_minute_version,omitempty" db:"two_minute_version"`
	StackAfterHabitID *string    `json:"stack_after_habit_id,omitempty" db:"stack_after_habit_id"`
	IsNegative        bool       `json:"is_negative" db:"is_negative"`
	Archived          bool       `json:"archived" db:"archived"`
	CreatedAt         time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at" db:"updated_at"`

	// Optional joined fields
	StackAfterHabit *Habit         `json:"stack_after_habit,omitempty" db:"-"`
	Checkins        []Checkin      `json:"checkins,omitempty" db:"-"`
	CurrentStreak   int            `json:"current_streak,omitempty" db:"-"`
	Subtasks        []HabitSubtask `json:"subtasks,omitempty" db:"-"`
}

// HabitCreateRequest represents the request for creating a habit
type HabitCreateRequest struct {
	Name              string          `json:"name" binding:"required" validate:"required,max=255"`
	Icon              *string         `json:"icon,omitempty" validate:"omitempty,max=100"`
	Color             *string         `json:"color,omitempty" validate:"omitempty,max=50"`
	Frequency         Frequency       `json:"frequency" binding:"required" validate:"required"`
	Note              *string         `json:"note,omitempty"`
	TwoMinuteVersion  *string         `json:"two_minute_version,omitempty"`
	StackAfterHabitID *string         `json:"stack_after_habit_id,omitempty"`
	IsNegative        bool            `json:"is_negative"`
	Subtasks          []SubtaskRequest `json:"subtasks,omitempty"`
}

// HabitUpdateRequest represents the request for updating a habit
type HabitUpdateRequest struct {
	Name              *string          `json:"name,omitempty"`
	Icon              *string          `json:"icon,omitempty"`
	Color             *string          `json:"color,omitempty"`
	Frequency         *Frequency       `json:"frequency,omitempty"`
	Note              *string          `json:"note,omitempty"`
	TwoMinuteVersion  *string          `json:"two_minute_version,omitempty"`
	StackAfterHabitID *string          `json:"stack_after_habit_id,omitempty"`
	IsNegative        *bool            `json:"is_negative,omitempty"`
	Archived          *bool            `json:"archived,omitempty"`
	Subtasks          []SubtaskRequest `json:"subtasks,omitempty"`
}

// Frequency represents the habit frequency configuration
type Frequency struct {
	Type         string `json:"type"` // "daily", "weekly", "times_per_week", "interval"
	TimesPerDay  int    `json:"times_per_day,omitempty"`
	Days         []int  `json:"days,omitempty"`      // 0-6 for weekly specific days
	Times        int    `json:"times,omitempty"`     // for times_per_week
	EveryNDays   int    `json:"every_n_days,omitempty"` // for interval
}

// TableName returns the database table name for the Habit model
func (Habit) TableName() string {
	return "habits"
}