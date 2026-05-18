package models

import "time"

type DailyLog struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Date      time.Time `json:"date"`
	Mood      *int      `json:"mood,omitempty"`
	Energy    *int      `json:"energy,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type DailyLogRequest struct {
	Date   string `json:"date" binding:"required"`
	Mood   *int   `json:"mood,omitempty"`
	Energy *int   `json:"energy,omitempty"`
}

type EnergyCorrelationPoint struct {
	EnergyLevel    int     `json:"energy_level"`
	CompletionRate float64 `json:"completion_rate"`
}
