package routes

import (
	"momentum/config"
	"momentum/controllers"
	"momentum/db"
	"momentum/middleware"
	"momentum/repositories"
	"momentum/services"

	"github.com/gin-gonic/gin"
)

func SetupRouter(cfg *config.Config) *gin.Engine {
	router := gin.Default()
	router.SetTrustedProxies(nil)
	router.Use(middleware.CORS())

	// Health check
	router.GET("/health", func(c *gin.Context) {
		dbStatus := "OK"
		if err := db.HealthCheck(); err != nil {
			dbStatus = "ERROR: " + err.Error()
		}
		var dbStats gin.H
		if stats := db.GetStats(); stats != nil {
			dbStats = gin.H{
				"total_conns":    stats.TotalConns(),
				"acquired_conns": stats.AcquiredConns(),
				"idle_conns":     stats.IdleConns(),
			}
		}
		c.JSON(200, gin.H{
			"status":   "OK",
			"message":  "Momentum API is running",
			"database": dbStatus,
			"db_stats": dbStats,
		})
	})

	// Wire dependencies
	userRepo := repositories.NewUserRepository()
	authService := services.NewAuthService(userRepo, cfg.JWTSecret)
	authController := controllers.NewAuthController(authService)

	habitRepo := repositories.NewHabitRepository()
	subtaskRepo := repositories.NewSubtaskRepository()
	templateRepo := repositories.NewTemplateRepository()
	habitService := services.NewHabitService(habitRepo, subtaskRepo, templateRepo)
	habitController := controllers.NewHabitController(habitService)

	milestoneRepo := repositories.NewMilestoneRepository()
	graceDayRepo := repositories.NewGraceDayRepository()
	dailyLogRepo := repositories.NewDailyLogRepository()

	checkinRepo := repositories.NewCheckinRepository()
	checkinService := services.NewCheckinService(checkinRepo, habitRepo, milestoneRepo, graceDayRepo, dailyLogRepo)
	checkinController := controllers.NewCheckinController(checkinService)

	insightsRepo := repositories.NewInsightsRepository()
	insightsService := services.NewInsightsService(insightsRepo, habitRepo, dailyLogRepo)
	insightsController := controllers.NewInsightsController(insightsService)

	// Auth routes (public)
	api := router.Group("/api")
	auth := api.Group("/auth")
	{
		auth.POST("/login", authController.Login)
		auth.POST("/register", authController.Register)
	}

	// Protected routes
	protected := api.Group("")
	protected.Use(middleware.AuthRequired(authService))
	{
		protected.GET("/insights", insightsController.GetInsights)
		protected.POST("/daily-log", checkinController.UpsertDailyLog)
		protected.GET("/daily-log", checkinController.GetDailyLog)

		habits := protected.Group("/habits")
		{
			habits.GET("", habitController.ListHabits)
			habits.GET("/archived", habitController.ListArchivedHabits)
			habits.POST("", habitController.CreateHabit)
			habits.PUT("/:id", habitController.UpdateHabit)
			habits.DELETE("/:id", habitController.ArchiveHabit)
			habits.POST("/:id/checkins", checkinController.LogCheckin)
			habits.DELETE("/:id/checkins", checkinController.DeleteTodayCheckin)
			habits.POST("/:id/grace", checkinController.ClaimGraceDay)
			habits.GET("/:id/streak", checkinController.GetStreak)
			habits.GET("/:id/history", checkinController.GetHistory)
			habits.POST("/:id/subtask-checkin", habitController.SubtaskCheckin)
		}

		templates := protected.Group("/templates")
		{
			templates.GET("", habitController.ListTemplates)
			templates.POST("/:id/adopt", habitController.AdoptTemplate)
		}
	}

	return router
}
