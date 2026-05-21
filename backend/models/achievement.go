package models

import (
	"encoding/json"
	"time"
)

type Achievement struct {
	ID          string          `json:"id"`
	Name        string          `json:"name"`
	Description string          `json:"description"`
	Icon        string          `json:"icon"`
	Criteria    json.RawMessage `json:"criteria"`
	SortOrder   int             `json:"sort_order"`
}

type UserAchievement struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	AchievementID string    `json:"achievement_id"`
	EarnedAt      time.Time `json:"earned_at"`
}

type UserAchievementProgress struct {
	UserID        string          `json:"user_id"`
	AchievementID string          `json:"achievement_id"`
	CurrentValue  int             `json:"current_value"`
	TargetValue   int             `json:"target_value"`
	Metadata      json.RawMessage `json:"metadata"`
	UpdatedAt     time.Time       `json:"updated_at"`
}

type AchievementItem struct {
	ID          string     `json:"id"`
	Name        string     `json:"name"`
	Description string     `json:"description"`
	Icon        string     `json:"icon"`
	EarnedAt    *time.Time `json:"earned_at,omitempty"`
}

type ProgressItem struct {
	ID           string `json:"id"`
	Name         string `json:"name"`
	Description  string `json:"description"`
	Icon         string `json:"icon"`
	CurrentValue int    `json:"current_value"`
	TargetValue  int    `json:"target_value"`
}

type AchievementsResponse struct {
	Earned      []AchievementItem `json:"earned"`
	InProgress  []ProgressItem    `json:"in_progress"`
	NewlyEarned []string          `json:"newly_earned"`
}

type AchievementEvent struct {
	UserID    string
	HabitID   string
	Timestamp time.Time
}
