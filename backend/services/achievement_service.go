package services

import (
	"context"
	"time"

	"cadence/models"
	"cadence/repositories"
	"cadence/services/evaluators"
)

type AchievementService struct {
	repo       *repositories.AchievementRepository
	evaluators []evaluators.Evaluator
}

func NewAchievementService(repo *repositories.AchievementRepository) *AchievementService {
	return &AchievementService{
		repo: repo,
		evaluators: []evaluators.Evaluator{
			&evaluators.FirstSteps{},
			&evaluators.WeekOne{},
			&evaluators.InTheFlow{},
			&evaluators.PerfectWeek{},
			&evaluators.TheComeback{},
			&evaluators.EarlyBird{},
			&evaluators.NightOwl{},
			&evaluators.ThePhilosopher{},
		},
	}
}

// EvaluateCheckin runs all evaluators for a checkin event and returns newly earned achievement IDs.
func (s *AchievementService) EvaluateCheckin(userID string, timestamp time.Time) ([]string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	event := models.AchievementEvent{
		UserID:    userID,
		Timestamp: timestamp,
	}

	var newlyEarned []string
	for _, ev := range s.evaluators {
		earned, err := s.repo.IsEarned(ctx, userID, ev.AchievementID())
		if err != nil {
			return newlyEarned, err
		}
		if earned {
			continue
		}

		progress, isEarned, err := ev.Evaluate(ctx, userID, event)
		if err != nil {
			// Log but don't fail the checkin over an achievement error.
			continue
		}

		if ev.AchievementID() != "the_comeback" {
			// TheComeback manages its own upsert internally due to metadata complexity.
			if err := s.repo.UpsertProgress(ctx, userID, ev.AchievementID(), progress, ev.TargetValue(), nil); err != nil {
				continue
			}
		}

		if isEarned {
			if err := s.repo.InsertEarned(ctx, userID, ev.AchievementID(), timestamp); err != nil {
				continue
			}
			newlyEarned = append(newlyEarned, ev.AchievementID())
		}
	}
	return newlyEarned, nil
}

// GetAchievements returns the full board state for a user.
func (s *AchievementService) GetAchievements(userID string) (*models.AchievementsResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	earned, err := s.repo.GetEarnedByUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	inProgress, err := s.repo.GetProgressByUser(ctx, userID)
	if err != nil {
		return nil, err
	}

	if earned == nil {
		earned = []models.AchievementItem{}
	}
	if inProgress == nil {
		inProgress = []models.ProgressItem{}
	}

	return &models.AchievementsResponse{
		Earned:      earned,
		InProgress:  inProgress,
		NewlyEarned: []string{},
	}, nil
}
