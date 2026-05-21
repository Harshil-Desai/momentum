package evaluators

import (
	"context"
	"encoding/json"
	"time"

	"cadence/db"
	"cadence/models"
)

type TheComeback struct{}

func (e *TheComeback) AchievementID() string { return "the_comeback" }
func (e *TheComeback) TargetValue() int      { return 14 }

type comebackMeta struct {
	Phase           string `json:"phase"`            // "watching" | "rebuilding"
	BrokenStreakEnd string `json:"broken_streak_end"` // YYYY-MM-DD
	RebuildStart    string `json:"rebuild_start"`     // YYYY-MM-DD
}

func (e *TheComeback) Evaluate(ctx context.Context, userID string, _ models.AchievementEvent) (int, bool, error) {
	windows, err := allStreakWindows(ctx, userID)
	if err != nil {
		return 0, false, err
	}

	today := time.Now().UTC().Truncate(24 * time.Hour)

	// Find the most recent current streak window (ends today or yesterday).
	var currentStreak streakWindow
	var pastStreaks []streakWindow
	for _, w := range windows {
		daysSinceEnd := int(today.Sub(w.End.UTC().Truncate(24 * time.Hour)).Hours() / 24)
		if daysSinceEnd <= 1 {
			currentStreak = w
		} else {
			pastStreaks = append(pastStreaks, w)
		}
	}

	// Look for a past streak of >= 14 that is broken (not the current one).
	var brokenStreak *streakWindow
	for i := range pastStreaks {
		if pastStreaks[i].Len >= 14 {
			brokenStreak = &pastStreaks[i]
			break
		}
	}

	if brokenStreak == nil {
		// No qualifying broken streak found yet. Progress = 0 in watching phase.
		meta, _ := json.Marshal(comebackMeta{Phase: "watching"})
		_ = upsertComebackProgress(ctx, userID, 0, meta)
		return 0, false, nil
	}

	// We have a broken streak. Track rebuild progress.
	rebuildLen := currentStreak.Len
	if currentStreak.Start.IsZero() {
		rebuildLen = 0
	}
	// Only count rebuild days after the broken streak ended.
	if !currentStreak.Start.IsZero() && !currentStreak.Start.After(brokenStreak.End) {
		rebuildLen = 0
	}

	meta, _ := json.Marshal(comebackMeta{
		Phase:           "rebuilding",
		BrokenStreakEnd: brokenStreak.End.Format("2006-01-02"),
		RebuildStart:    currentStreak.Start.Format("2006-01-02"),
	})
	_ = upsertComebackProgress(ctx, userID, rebuildLen, meta)

	progress := min(rebuildLen, 14)
	return progress, rebuildLen >= 14, nil
}

func upsertComebackProgress(ctx context.Context, userID string, current int, meta json.RawMessage) error {
	_, err := db.Pool.Exec(ctx, `
		INSERT INTO user_achievement_progress
			(user_id, achievement_id, current_value, target_value, metadata, updated_at)
		VALUES ($1, 'the_comeback', $2, 14, $3, NOW())
		ON CONFLICT (user_id, achievement_id)
		DO UPDATE SET current_value = $2, metadata = $3, updated_at = NOW()
	`, userID, current, meta)
	return err
}
