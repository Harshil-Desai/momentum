package repositories

import (
	"context"
	"encoding/json"
	"time"

	"cadence/db"
	"cadence/models"
)

type AchievementRepository struct{}

func NewAchievementRepository() *AchievementRepository {
	return &AchievementRepository{}
}

func (r *AchievementRepository) IsEarned(ctx context.Context, userID, achievementID string) (bool, error) {
	var exists bool
	err := db.Pool.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM user_achievements
			WHERE user_id = $1 AND achievement_id = $2
		)
	`, userID, achievementID).Scan(&exists)
	return exists, err
}

func (r *AchievementRepository) InsertEarned(ctx context.Context, userID, achievementID string, earnedAt time.Time) error {
	_, err := db.Pool.Exec(ctx, `
		INSERT INTO user_achievements (user_id, achievement_id, earned_at)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id, achievement_id) DO NOTHING
	`, userID, achievementID, earnedAt)
	return err
}

func (r *AchievementRepository) UpsertProgress(ctx context.Context, userID, achievementID string, current, target int, metadata json.RawMessage) error {
	if metadata == nil {
		metadata = json.RawMessage("{}")
	}
	_, err := db.Pool.Exec(ctx, `
		INSERT INTO user_achievement_progress
			(user_id, achievement_id, current_value, target_value, metadata, updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (user_id, achievement_id)
		DO UPDATE SET current_value = $3, target_value = $4, metadata = $5, updated_at = NOW()
	`, userID, achievementID, current, target, metadata)
	return err
}

func (r *AchievementRepository) GetProgress(ctx context.Context, userID, achievementID string) (*models.UserAchievementProgress, error) {
	row := db.Pool.QueryRow(ctx, `
		SELECT user_id, achievement_id, current_value, target_value, metadata, updated_at
		FROM user_achievement_progress
		WHERE user_id = $1 AND achievement_id = $2
	`, userID, achievementID)

	var p models.UserAchievementProgress
	err := row.Scan(&p.UserID, &p.AchievementID, &p.CurrentValue, &p.TargetValue, &p.Metadata, &p.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *AchievementRepository) GetEarnedByUser(ctx context.Context, userID string) ([]models.AchievementItem, error) {
	rows, err := db.Pool.Query(ctx, `
		SELECT a.id, a.name, a.description, a.icon, ua.earned_at
		FROM user_achievements ua
		JOIN achievements a ON a.id = ua.achievement_id
		WHERE ua.user_id = $1
		ORDER BY ua.earned_at DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []models.AchievementItem
	for rows.Next() {
		var item models.AchievementItem
		if err := rows.Scan(&item.ID, &item.Name, &item.Description, &item.Icon, &item.EarnedAt); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *AchievementRepository) GetProgressByUser(ctx context.Context, userID string) ([]models.ProgressItem, error) {
	rows, err := db.Pool.Query(ctx, `
		SELECT a.id, a.name, a.description, a.icon, p.current_value, p.target_value
		FROM user_achievement_progress p
		JOIN achievements a ON a.id = p.achievement_id
		WHERE p.user_id = $1
		  AND NOT EXISTS (
			SELECT 1 FROM user_achievements ua
			WHERE ua.user_id = $1 AND ua.achievement_id = p.achievement_id
		  )
		ORDER BY a.sort_order
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []models.ProgressItem
	for rows.Next() {
		var item models.ProgressItem
		if err := rows.Scan(&item.ID, &item.Name, &item.Description, &item.Icon, &item.CurrentValue, &item.TargetValue); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}
