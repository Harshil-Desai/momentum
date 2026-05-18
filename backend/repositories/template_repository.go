package repositories

import (
	"context"
	"encoding/json"
	"time"

	"momentum/db"
	"momentum/models"
)

type TemplateRepository struct{}

func NewTemplateRepository() *TemplateRepository { return &TemplateRepository{} }

func (r *TemplateRepository) List() ([]models.HabitTemplate, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := db.Pool.Query(ctx,
		`SELECT id, name, icon, color, frequency, note, two_minute_version, category, sort_order
		 FROM habit_templates ORDER BY category, sort_order`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var templates []models.HabitTemplate
	for rows.Next() {
		var t models.HabitTemplate
		var freqJSON []byte
		if err := rows.Scan(&t.ID, &t.Name, &t.Icon, &t.Color, &freqJSON,
			&t.Note, &t.TwoMinuteVersion, &t.Category, &t.SortOrder); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(freqJSON, &t.Frequency); err != nil {
			return nil, err
		}
		templates = append(templates, t)
	}
	return templates, rows.Err()
}
