package services

import (
	"errors"
	"fmt"
	"time"

	"cadence/models"
	"cadence/repositories"
)

var ErrFutureDate = errors.New("checkin date cannot be in the future")
var ErrCheckinHabitNotFound = errors.New("habit not found")
var ErrGraceDayAlreadyUsed = repositories.ErrGraceDayAlreadyUsed
var ErrGraceDayNotEligible = errors.New("streak was not at risk — no grace day needed")

type CheckinService struct {
	checkinRepo        *repositories.CheckinRepository
	habitRepo          *repositories.HabitRepository
	milestoneRepo      *repositories.MilestoneRepository
	graceDayRepo       *repositories.GraceDayRepository
	dailyLogRepo       *repositories.DailyLogRepository
	achievementService *AchievementService
}

func NewCheckinService(
	checkinRepo *repositories.CheckinRepository,
	habitRepo *repositories.HabitRepository,
	milestoneRepo *repositories.MilestoneRepository,
	graceDayRepo *repositories.GraceDayRepository,
	dailyLogRepo *repositories.DailyLogRepository,
	achievementService *AchievementService,
) *CheckinService {
	return &CheckinService{
		checkinRepo:        checkinRepo,
		habitRepo:          habitRepo,
		milestoneRepo:      milestoneRepo,
		graceDayRepo:       graceDayRepo,
		dailyLogRepo:       dailyLogRepo,
		achievementService: achievementService,
	}
}

// DeleteTodayCheckin removes today's check-in for the given habit.
func (s *CheckinService) DeleteTodayCheckin(userID, habitID string) error {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return ErrCheckinHabitNotFound
	}
	return s.checkinRepo.DeleteToday(userID, habitID)
}

// LogCheckin records a check-in and returns the checkin, whether it was newly
// created, any milestone value just reached (0 = none), and newly earned achievement IDs.
func (s *CheckinService) LogCheckin(userID, habitID, dateStr string) (*models.Checkin, bool, int, []string, error) {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return nil, false, 0, nil, fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return nil, false, 0, nil, ErrCheckinHabitNotFound
	}

	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return nil, false, 0, nil, fmt.Errorf("invalid date format, expected YYYY-MM-DD")
	}

	today := time.Now().UTC().Truncate(24 * time.Hour)
	if date.After(today) {
		return nil, false, 0, nil, ErrFutureDate
	}

	checkin := &models.Checkin{
		UserID:  userID,
		HabitID: habitID,
		Date:    date,
	}

	created, err := s.checkinRepo.Create(checkin)
	if err != nil {
		return nil, false, 0, nil, fmt.Errorf("logging checkin: %w", err)
	}

	var milestoneReached int
	if created {
		count, err := s.milestoneRepo.CountCheckins(userID, habitID)
		if err == nil {
			milestoneReached, _ = s.milestoneRepo.RecordIfNew(userID, habitID, count)
		}
	}

	var newlyEarned []string
	if created {
		newlyEarned, _ = s.achievementService.EvaluateCheckin(userID, checkin.CreatedAt)
	}

	return checkin, created, milestoneReached, newlyEarned, nil
}

// ClaimGraceDay protects yesterday's missed date for a habit. Returns an error
// if a grace day was already used this month or the streak wasn't at risk.
func (s *CheckinService) ClaimGraceDay(userID, habitID string) error {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return ErrCheckinHabitNotFound
	}

	yesterday := time.Now().UTC().Truncate(24 * time.Hour).AddDate(0, 0, -1)
	return s.graceDayRepo.Claim(userID, habitID, yesterday)
}

// UpsertDailyLog saves mood/energy for the given day.
func (s *CheckinService) UpsertDailyLog(userID, dateStr string, mood, energy *int) (*models.DailyLog, error) {
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return nil, fmt.Errorf("invalid date format, expected YYYY-MM-DD")
	}
	log := &models.DailyLog{
		UserID: userID,
		Date:   date,
		Mood:   mood,
		Energy: energy,
	}
	if err := s.dailyLogRepo.Upsert(log); err != nil {
		return nil, fmt.Errorf("upserting daily log: %w", err)
	}
	return log, nil
}

// GetDailyLog returns the log for the given date, or nil if none.
func (s *CheckinService) GetDailyLog(userID, dateStr string) (*models.DailyLog, error) {
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return nil, fmt.Errorf("invalid date format, expected YYYY-MM-DD")
	}
	return s.dailyLogRepo.FindByDate(userID, date)
}

type HistoryResult struct {
	Dates              []string
	LifetimeCount      int
	CheckedToday       bool
	MissedYesterday    bool
	GraceUsedThisMonth bool
	CanClaimGrace      bool
}

func (s *CheckinService) GetHistory(userID, habitID string) (*HistoryResult, error) {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return nil, fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return nil, ErrCheckinHabitNotFound
	}

	dates, count, err := s.checkinRepo.GetHistory(userID, habitID)
	if err != nil {
		return nil, fmt.Errorf("getting history: %w", err)
	}

	strs := make([]string, len(dates))
	for i, d := range dates {
		strs[i] = d.Format("2006-01-02")
	}

	today := time.Now().UTC().Format("2006-01-02")
	yesterday := time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02")
	dateSet := make(map[string]bool, len(strs))
	for _, d := range strs {
		dateSet[d] = true
	}
	checkedToday := dateSet[today]
	missedYesterday := !dateSet[yesterday] && !checkedToday

	graceUsed, _ := s.graceDayRepo.UsedThisMonth(userID, habitID)
	canClaim := missedYesterday && !graceUsed

	return &HistoryResult{
		Dates:              strs,
		LifetimeCount:      count,
		CheckedToday:       checkedToday,
		MissedYesterday:    missedYesterday,
		GraceUsedThisMonth: graceUsed,
		CanClaimGrace:      canClaim,
	}, nil
}

func (s *CheckinService) GetStreak(userID, habitID string) (int, error) {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return 0, fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return 0, ErrCheckinHabitNotFound
	}

	dates, _, err := s.checkinRepo.GetHistory(userID, habitID)
	if err != nil {
		return 0, fmt.Errorf("getting history: %w", err)
	}
	return ComputeStreak(habit.Frequency, dates), nil
}
