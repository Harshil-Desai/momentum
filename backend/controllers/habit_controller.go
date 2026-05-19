package controllers

import (
	"errors"
	"net/http"

	"cadence/middleware"
	"cadence/models"
	"cadence/services"

	"github.com/gin-gonic/gin"
)

type HabitController struct {
	habitService *services.HabitService
}

func NewHabitController(habitService *services.HabitService) *HabitController {
	return &HabitController{habitService: habitService}
}

func (hc *HabitController) ListHabits(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)

	habits, err := hc.habitService.ListHabits(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve habits"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"habits": habits,
		"count":  len(habits),
	})
}

func (hc *HabitController) CreateHabit(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)

	var req models.HabitCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "details": err.Error()})
		return
	}

	habit, err := hc.habitService.CreateHabit(userID, req)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, habit)
}

func (hc *HabitController) ListArchivedHabits(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)

	habits, err := hc.habitService.ListArchivedHabits(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve archived habits"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"habits": habits, "count": len(habits)})
}

func (hc *HabitController) UpdateHabit(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	var req models.HabitUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "details": err.Error()})
		return
	}

	habit, err := hc.habitService.UpdateHabit(habitID, userID, req)
	if err != nil {
		switch {
		case errors.Is(err, services.ErrHabitNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		case errors.Is(err, services.ErrCyclicStack):
			c.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update habit"})
		}
		return
	}

	c.JSON(http.StatusOK, habit)
}

func (hc *HabitController) ArchiveHabit(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	if err := hc.habitService.ArchiveHabit(habitID, userID); err != nil {
		if errors.Is(err, services.ErrHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to archive habit"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Habit archived"})
}

// ListTemplates handles GET /templates
func (hc *HabitController) ListTemplates(c *gin.Context) {
	templates, err := hc.habitService.ListTemplates()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load templates"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"templates": templates})
}

// AdoptTemplate handles POST /templates/:id/adopt
func (hc *HabitController) AdoptTemplate(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	templateID := c.Param("id")

	habit, err := hc.habitService.AdoptTemplate(userID, templateID)
	if err != nil {
		if errors.Is(err, services.ErrTemplateNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Template not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to adopt template"})
		return
	}
	c.JSON(http.StatusCreated, habit)
}

// SubtaskCheckin handles POST /habits/:id/subtask-checkin
func (hc *HabitController) SubtaskCheckin(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	habitID := c.Param("id")

	var req models.SubtaskCheckinRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	if err := hc.habitService.UpsertSubtaskCheckin(userID, habitID, req); err != nil {
		if errors.Is(err, services.ErrHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save subtask checkin"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Subtask checkin saved"})
}
