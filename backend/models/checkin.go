package models

import (
	"time"
)

// Checkin represents a habit checkin in the system
type Checkin struct {
	ID        string    `json:"id" db:"id"`
	UserID    string    `json:"user_id" db:"user_id"`
	HabitID   string    `json:"habit_id" db:"habit_id"`
	Date      time.Time `json:"date" db:"date"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	
	// Optional joined fields
	Habit *Habit `json:"habit,omitempty" db:"-"`
	User  *User  `json:"user,omitempty" db:"-"`
}

// CheckinCreateRequest represents the request for creating a checkin
type CheckinCreateRequest struct {
	HabitID string    `json:"habit_id" binding:"required"`
	Date    time.Time `json:"date" binding:"required"`
}

// CheckinResponse represents the checkin data returned in responses
type CheckinResponse struct {
	ID               string    `json:"id"`
	UserID           string    `json:"user_id"`
	HabitID          string    `json:"habit_id"`
	Date             time.Time `json:"date"`
	CreatedAt        time.Time `json:"created_at"`
	MilestoneReached *int      `json:"milestone_reached,omitempty"`
}

// CheckinStats represents statistics for checkins
type CheckinStats struct {
	TotalCheckins  int       `json:"total_checkins"`
	CurrentStreak  int       `json:"current_streak"`
	LongestStreak  int       `json:"longest_streak"`
	MonthlyCount   int       `json:"monthly_count"`
	LastCheckin    time.Time `json:"last_checkin,omitempty"`
}

// ToResponse converts a Checkin to CheckinResponse
func (c *Checkin) ToResponse() *CheckinResponse {
	return &CheckinResponse{
		ID:        c.ID,
		UserID:    c.UserID,
		HabitID:   c.HabitID,
		Date:      c.Date,
		CreatedAt: c.CreatedAt,
	}
}

// TableName returns the database table name for the Checkin model
func (Checkin) TableName() string {
	return "checkins"
}