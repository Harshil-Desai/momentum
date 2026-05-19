package services

import (
	"errors"
	"fmt"
	"time"

	"cadence/models"
	"cadence/repositories"
)

var ErrHabitNotFound = errors.New("habit not found")
var ErrCyclicStack = errors.New("habit stack would create a cycle")
var ErrTemplateNotFound = errors.New("template not found")

type HabitService struct {
	habitRepo    *repositories.HabitRepository
	subtaskRepo  *repositories.SubtaskRepository
	templateRepo *repositories.TemplateRepository
}

func NewHabitService(
	habitRepo *repositories.HabitRepository,
	subtaskRepo *repositories.SubtaskRepository,
	templateRepo *repositories.TemplateRepository,
) *HabitService {
	return &HabitService{habitRepo: habitRepo, subtaskRepo: subtaskRepo, templateRepo: templateRepo}
}

func (s *HabitService) CreateHabit(userID string, req models.HabitCreateRequest) (*models.Habit, error) {
	habit := &models.Habit{
		UserID:            userID,
		Name:              req.Name,
		Icon:              req.Icon,
		Color:             req.Color,
		Frequency:         req.Frequency,
		Note:              req.Note,
		TwoMinuteVersion:  req.TwoMinuteVersion,
		StackAfterHabitID: req.StackAfterHabitID,
		IsNegative:        req.IsNegative,
	}

	if err := s.habitRepo.Create(habit); err != nil {
		return nil, fmt.Errorf("creating habit: %w", err)
	}

	if len(req.Subtasks) > 0 {
		subtasks, err := s.subtaskRepo.ReplaceAll(habit.ID, req.Subtasks)
		if err != nil {
			return nil, fmt.Errorf("creating subtasks: %w", err)
		}
		habit.Subtasks = subtasks
	}

	return habit, nil
}

func (s *HabitService) ListHabits(userID string) ([]*models.Habit, error) {
	habits, err := s.habitRepo.ListByUser(userID)
	if err != nil {
		return nil, fmt.Errorf("listing habits: %w", err)
	}
	if habits == nil {
		return []*models.Habit{}, nil
	}
	// Attach subtasks to each habit
	for _, h := range habits {
		subtasks, err := s.subtaskRepo.ListByHabit(h.ID)
		if err == nil {
			h.Subtasks = subtasks
		}
	}
	return habits, nil
}

func (s *HabitService) UpdateHabit(habitID, userID string, req models.HabitUpdateRequest) (*models.Habit, error) {
	if req.StackAfterHabitID != nil && *req.StackAfterHabitID != "" {
		if err := s.detectStackCycle(habitID, *req.StackAfterHabitID, userID); err != nil {
			return nil, err
		}
	}
	habit, err := s.habitRepo.Update(habitID, userID, req)
	if err != nil {
		return nil, fmt.Errorf("updating habit: %w", err)
	}
	if habit == nil {
		return nil, ErrHabitNotFound
	}
	if req.Subtasks != nil {
		subtasks, err := s.subtaskRepo.ReplaceAll(habitID, req.Subtasks)
		if err != nil {
			return nil, fmt.Errorf("updating subtasks: %w", err)
		}
		habit.Subtasks = subtasks
	} else {
		subtasks, _ := s.subtaskRepo.ListByHabit(habitID)
		habit.Subtasks = subtasks
	}
	return habit, nil
}

func (s *HabitService) ListArchivedHabits(userID string) ([]*models.Habit, error) {
	habits, err := s.habitRepo.ListArchived(userID)
	if err != nil {
		return nil, fmt.Errorf("listing archived habits: %w", err)
	}
	if habits == nil {
		return []*models.Habit{}, nil
	}
	return habits, nil
}

func (s *HabitService) ArchiveHabit(habitID, userID string) error {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return ErrHabitNotFound
	}
	return s.habitRepo.Archive(habitID, userID)
}

// AdoptTemplate creates a habit from a template for the given user.
func (s *HabitService) AdoptTemplate(userID, templateID string) (*models.Habit, error) {
	templates, err := s.templateRepo.List()
	if err != nil {
		return nil, fmt.Errorf("loading templates: %w", err)
	}
	var tmpl *models.HabitTemplate
	for i := range templates {
		if templates[i].ID == templateID {
			tmpl = &templates[i]
			break
		}
	}
	if tmpl == nil {
		return nil, ErrTemplateNotFound
	}
	req := models.HabitCreateRequest{
		Name:             tmpl.Name,
		Icon:             tmpl.Icon,
		Color:            tmpl.Color,
		Frequency:        tmpl.Frequency,
		Note:             tmpl.Note,
		TwoMinuteVersion: tmpl.TwoMinuteVersion,
		IsNegative:       tmpl.IsNegative,
	}
	return s.CreateHabit(userID, req)
}

// ListTemplates returns all habit templates grouped by category.
func (s *HabitService) ListTemplates() ([]models.HabitTemplate, error) {
	return s.templateRepo.List()
}

// UpsertSubtaskCheckin saves which subtasks were completed for a given habit+date.
func (s *HabitService) UpsertSubtaskCheckin(userID, habitID string, req models.SubtaskCheckinRequest) error {
	habit, err := s.habitRepo.FindByID(habitID, userID)
	if err != nil {
		return fmt.Errorf("finding habit: %w", err)
	}
	if habit == nil {
		return ErrHabitNotFound
	}
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		return fmt.Errorf("invalid date format, expected YYYY-MM-DD")
	}
	return s.subtaskRepo.UpsertCheckinSubtasks(userID, habitID, date, req.CompletedIDs)
}

// detectStackCycle walks the stack_after_habit_id chain and returns ErrCyclicStack
// if habitID appears in the chain starting from targetID.
func (s *HabitService) detectStackCycle(habitID, targetID, userID string) error {
	visited := map[string]bool{habitID: true}
	current := targetID
	for current != "" {
		if visited[current] {
			return ErrCyclicStack
		}
		visited[current] = true
		h, err := s.habitRepo.FindByID(current, userID)
		if err != nil || h == nil {
			break
		}
		if h.StackAfterHabitID == nil {
			break
		}
		current = *h.StackAfterHabitID
	}
	return nil
}

// ComputeStreak calculates streak in Go based on frequency type.
func ComputeStreak(freq models.Frequency, dates []time.Time) int {
	if len(dates) == 0 {
		return 0
	}

	switch freq.Type {
	case "times_per_week":
		return computeTimesPerWeekStreak(dates, freq.Times)
	case "interval":
		return computeIntervalStreak(dates, freq.EveryNDays)
	default:
		// daily / weekly (specific days) — count consecutive days from today
		return computeDailyStreak(dates)
	}
}

func computeDailyStreak(dates []time.Time) int {
	if len(dates) == 0 {
		return 0
	}
	dateSet := make(map[string]bool, len(dates))
	for _, d := range dates {
		dateSet[d.UTC().Format("2006-01-02")] = true
	}
	streak := 0
	check := time.Now().UTC().Truncate(24 * time.Hour)
	for {
		if dateSet[check.Format("2006-01-02")] {
			streak++
			check = check.AddDate(0, 0, -1)
		} else {
			break
		}
	}
	return streak
}

func isoWeekKey(t time.Time) string {
	year, week := t.ISOWeek()
	return fmt.Sprintf("%d-W%02d", year, week)
}

func computeTimesPerWeekStreak(dates []time.Time, target int) int {
	if target <= 0 {
		target = 1
	}
	// Count checkins per ISO week
	weekCounts := make(map[string]int)
	for _, d := range dates {
		weekCounts[isoWeekKey(d)]++
	}
	streak := 0
	now := time.Now().UTC()
	// Walk back week by week
	for {
		key := isoWeekKey(now)
		if weekCounts[key] >= target {
			streak++
			now = now.AddDate(0, 0, -7)
		} else {
			break
		}
	}
	return streak
}

func computeIntervalStreak(dates []time.Time, everyN int) int {
	if everyN <= 0 {
		everyN = 1
	}
	if len(dates) == 0 {
		return 0
	}
	// Sort descending (most recent first)
	sorted := make([]time.Time, len(dates))
	copy(sorted, dates)
	for i := 0; i < len(sorted)-1; i++ {
		for j := i + 1; j < len(sorted); j++ {
			if sorted[j].After(sorted[i]) {
				sorted[i], sorted[j] = sorted[j], sorted[i]
			}
		}
	}

	streak := 1
	for i := 1; i < len(sorted); i++ {
		diff := int(sorted[i-1].UTC().Truncate(24*time.Hour).Sub(sorted[i].UTC().Truncate(24*time.Hour)).Hours() / 24)
		if diff <= everyN {
			streak++
		} else {
			break
		}
	}
	return streak
}
