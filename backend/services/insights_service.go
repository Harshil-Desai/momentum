package services

import (
	"fmt"
	"time"

	"momentum/models"
	"momentum/repositories"
)

var dayNames = []string{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}

const InsightsUnlockThreshold = 21

type InsightsData struct {
	TotalCheckins       int                                  `json:"total_checkins"`
	ActiveHabits        int                                  `json:"active_habits"`
	MonthlyCompleted    int                                  `json:"monthly_completed"`
	MonthlyPossible     int                                  `json:"monthly_possible"`
	MonthlyRate         float64                              `json:"monthly_rate"`
	DayOfWeek           []repositories.DayCount              `json:"day_of_week"`
	StrongestDay        string                               `json:"strongest_day"`
	HabitStreaks        []repositories.HabitStreakSummary    `json:"habit_streaks"`
	EnergyCorrelation   []models.EnergyCorrelationPoint      `json:"energy_correlation,omitempty"`
	// Advanced insights — only populated when MaxHabitCheckins >= InsightsUnlockThreshold
	Correlations        []repositories.HabitCorrelation      `json:"correlations,omitempty"`
	Forecasts           []repositories.HabitForecast         `json:"forecasts,omitempty"`
	MonthlyReview       *repositories.MonthlyReview          `json:"monthly_review,omitempty"`
	AdvancedUnlocked    bool                                  `json:"advanced_unlocked"`
	UnlockThreshold     int                                   `json:"unlock_threshold"`
	MaxHabitCheckins    int                                   `json:"max_habit_checkins"`
}

type InsightsService struct {
	insightsRepo *repositories.InsightsRepository
	habitRepo    *repositories.HabitRepository
	dailyLogRepo *repositories.DailyLogRepository
}

func NewInsightsService(insightsRepo *repositories.InsightsRepository, habitRepo *repositories.HabitRepository, dailyLogRepo *repositories.DailyLogRepository) *InsightsService {
	return &InsightsService{insightsRepo: insightsRepo, habitRepo: habitRepo, dailyLogRepo: dailyLogRepo}
}

func (s *InsightsService) GetInsights(userID string) (*InsightsData, error) {
	total, err := s.insightsRepo.TotalCheckins(userID)
	if err != nil {
		return nil, fmt.Errorf("total checkins: %w", err)
	}

	maxHabitCheckins, err := s.insightsRepo.MaxHabitCheckins(userID)
	if err != nil {
		return nil, fmt.Errorf("max habit checkins: %w", err)
	}

	dowCounts, err := s.insightsRepo.DayOfWeekCounts(userID)
	if err != nil {
		return nil, fmt.Errorf("day of week: %w", err)
	}

	completed, possible, err := s.insightsRepo.MonthlyRate(userID)
	if err != nil {
		return nil, fmt.Errorf("monthly rate: %w", err)
	}

	streaks, err := s.insightsRepo.HabitStreaks(userID)
	if err != nil {
		return nil, fmt.Errorf("habit streaks: %w", err)
	}

	rate := 0.0
	if possible > 0 {
		rate = float64(completed) / float64(possible)
	}

	strongest := strongestDay(dowCounts)

	energyCorr, _ := s.dailyLogRepo.EnergyCorrelation(userID)

	data := &InsightsData{
		TotalCheckins:    total,
		ActiveHabits:     len(streaks),
		MonthlyCompleted: completed,
		MonthlyPossible:  possible,
		MonthlyRate:      rate,
		DayOfWeek:        dowCounts,
		StrongestDay:     strongest,
		HabitStreaks:     streaks,
		EnergyCorrelation: energyCorr,
		AdvancedUnlocked:  maxHabitCheckins >= InsightsUnlockThreshold,
		UnlockThreshold:   InsightsUnlockThreshold,
		MaxHabitCheckins:  maxHabitCheckins,
	}

	if maxHabitCheckins >= InsightsUnlockThreshold {
		correlations, err := s.insightsRepo.GetHabitCorrelations(userID, 90)
		if err != nil {
			return nil, fmt.Errorf("correlations: %w", err)
		}
		data.Correlations = correlations

		dowRates, err := s.insightsRepo.GetDayOfWeekRates(userID, 12)
		if err != nil {
			return nil, fmt.Errorf("day of week rates: %w", err)
		}
		data.Forecasts = buildForecasts(dowRates)

		now := time.Now().UTC()
		review, err := s.insightsRepo.GetMonthlyReviewData(userID, now.Year(), int(now.Month()))
		if err != nil {
			return nil, fmt.Errorf("monthly review: %w", err)
		}
		data.MonthlyReview = review
	}

	return data, nil
}

func buildForecasts(rates []repositories.HabitForecast) []repositories.HabitForecast {
	tomorrow := int(time.Now().UTC().AddDate(0, 0, 1).Weekday())
	var forecasts []repositories.HabitForecast
	for _, f := range rates {
		if f.DayOfWeek != tomorrow {
			continue
		}
		f.NudgeCopy = buildNudgeCopy(f.CompletionRate, f.HabitName)
		forecasts = append(forecasts, f)
	}
	return forecasts
}

func buildNudgeCopy(rate float64, name string) string {
	switch {
	case rate >= 0.9:
		return fmt.Sprintf("You almost always do \"%s\" today — keep the streak alive!", name)
	case rate >= 0.7:
		return fmt.Sprintf("You usually complete \"%s\" on days like today — you've got this.", name)
	default:
		return fmt.Sprintf("Tomorrow's a great day to work on \"%s\".", name)
	}
}

func strongestDay(counts []repositories.DayCount) string {
	if len(counts) == 0 {
		return ""
	}
	best := counts[0]
	for _, c := range counts[1:] {
		if c.Count > best.Count {
			best = c
		}
	}
	if best.DayOfWeek < 0 || best.DayOfWeek > 6 {
		return ""
	}
	return dayNames[best.DayOfWeek]
}
