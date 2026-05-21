package controllers

import (
	"net/http"

	"cadence/middleware"
	"cadence/services"

	"github.com/gin-gonic/gin"
)

type AchievementController struct {
	service *services.AchievementService
}

func NewAchievementController(service *services.AchievementService) *AchievementController {
	return &AchievementController{service: service}
}

// GetAchievements handles GET /achievements
func (ac *AchievementController) GetAchievements(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)
	resp, err := ac.service.GetAchievements(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load achievements"})
		return
	}
	c.JSON(http.StatusOK, resp)
}
