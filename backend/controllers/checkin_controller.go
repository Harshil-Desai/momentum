package controllers

import (
	"errors"
	"net/http"

	"cadence/middleware"
	"cadence/services"

	"github.com/gin-gonic/gin"
)

type CheckinController struct {
	checkinService *services.CheckinService
}

func NewCheckinController(checkinService *services.CheckinService) *CheckinController {
	return &CheckinController{checkinService: checkinService}
}

// LogCheckin handles POST /habits/:id/checkins
func (cc *CheckinController) LogCheckin(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	var req struct {
		Date string `json:"date" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "date is required (YYYY-MM-DD)"})
		return
	}

	checkin, created, milestone, newlyEarned, err := cc.checkinService.LogCheckin(userID, habitID, req.Date)
	if err != nil {
		switch {
		case errors.Is(err, services.ErrFutureDate):
			c.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		case errors.Is(err, services.ErrCheckinHabitNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to log checkin"})
		}
		return
	}

	resp := checkin.ToResponse()
	if milestone > 0 {
		resp.MilestoneReached = &milestone
	}

	status := http.StatusOK
	if created {
		status = http.StatusCreated
	}
	if len(newlyEarned) > 0 {
		c.JSON(status, gin.H{"checkin": resp, "newly_earned_achievements": newlyEarned})
		return
	}
	c.JSON(status, resp)
}

// DeleteTodayCheckin handles DELETE /habits/:id/checkins
func (cc *CheckinController) DeleteTodayCheckin(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	if err := cc.checkinService.DeleteTodayCheckin(userID, habitID); err != nil {
		switch {
		case errors.Is(err, services.ErrCheckinHabitNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete checkin"})
		}
		return
	}
	c.Status(http.StatusNoContent)
}

// GetHistory handles GET /habits/:id/history
func (cc *CheckinController) GetHistory(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	result, err := cc.checkinService.GetHistory(userID, habitID)
	if err != nil {
		if errors.Is(err, services.ErrCheckinHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get history"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"dates":                result.Dates,
		"lifetime_count":       result.LifetimeCount,
		"checked_today":        result.CheckedToday,
		"missed_yesterday":     result.MissedYesterday,
		"grace_used_this_month": result.GraceUsedThisMonth,
		"can_claim_grace":      result.CanClaimGrace,
	})
}

// GetStreak handles GET /habits/:id/streak
func (cc *CheckinController) GetStreak(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	streak, err := cc.checkinService.GetStreak(userID, habitID)
	if err != nil {
		if errors.Is(err, services.ErrCheckinHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get streak"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"current_streak": streak})
}

// ClaimGraceDay handles POST /habits/:id/grace
func (cc *CheckinController) ClaimGraceDay(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	if err := cc.checkinService.ClaimGraceDay(userID, habitID); err != nil {
		switch {
		case errors.Is(err, services.ErrCheckinHabitNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		case errors.Is(err, services.ErrGraceDayAlreadyUsed):
			c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to claim grace day"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Streak protected"})
}

// UpsertDailyLog handles POST /daily-log
func (cc *CheckinController) UpsertDailyLog(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)

	var req struct {
		Date   string `json:"date" binding:"required"`
		Mood   *int   `json:"mood,omitempty"`
		Energy *int   `json:"energy,omitempty"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "date is required (YYYY-MM-DD)"})
		return
	}

	log, err := cc.checkinService.UpsertDailyLog(userID, req.Date, req.Mood, req.Energy)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, log)
}

// GetDailyLog handles GET /daily-log?date=YYYY-MM-DD
func (cc *CheckinController) GetDailyLog(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	dateStr := c.Query("date")
	if dateStr == "" {
		dateStr = c.GetString("today")
	}

	log, err := cc.checkinService.GetDailyLog(userID, dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if log == nil {
		c.JSON(http.StatusOK, gin.H{})
		return
	}
	c.JSON(http.StatusOK, log)
}
