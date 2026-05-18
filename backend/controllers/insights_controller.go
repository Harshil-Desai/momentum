package controllers

import (
	"net/http"

	"momentum/middleware"
	"momentum/services"

	"github.com/gin-gonic/gin"
)

type InsightsController struct {
	insightsService *services.InsightsService
}

func NewInsightsController(insightsService *services.InsightsService) *InsightsController {
	return &InsightsController{insightsService: insightsService}
}

func (ic *InsightsController) GetInsights(c *gin.Context) {
	userID := c.GetString(middleware.UserIDKey)

	data, err := ic.insightsService.GetInsights(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load insights"})
		return
	}

	c.JSON(http.StatusOK, data)
}
