package models

type HabitTemplate struct {
	ID                string    `json:"id"`
	Name              string    `json:"name"`
	Icon              *string   `json:"icon,omitempty"`
	Color             *string   `json:"color,omitempty"`
	Frequency         Frequency `json:"frequency"`
	Note              *string   `json:"note,omitempty"`
	TwoMinuteVersion  *string   `json:"two_minute_version,omitempty"`
	Category          string    `json:"category"`
	SortOrder         int       `json:"sort_order"`
}
