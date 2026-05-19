package main

import (
	"log"
	"cadence/config"
	"cadence/db"
	"cadence/routes"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	cfg := config.LoadConfig()

	dbConfig := &db.Config{
		URL:             cfg.DatabaseURL,
		MaxOpenConns:    cfg.DBMaxOpenConns,
		MaxIdleConns:    cfg.DBMaxIdleConns,
		ConnMaxLifetime: cfg.DBConnMaxLifetime,
	}

	// Apply defaults if not set via env
	if dbConfig.MaxOpenConns == 0 {
		dbConfig.MaxOpenConns = 25
	}
	if dbConfig.MaxIdleConns == 0 {
		dbConfig.MaxIdleConns = 25
	}
	if dbConfig.ConnMaxLifetime == 0 {
		dbConfig.ConnMaxLifetime = 5 * time.Minute
	}

	if err := db.InitDB(dbConfig); err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.CloseDB()

	migrationsPath := "./migrations/"
	result, err := db.RunMigrations(migrationsPath)
	if err != nil {
		log.Fatal("Failed to run migrations:", err)
	}
	if result.TotalApplied > 0 {
		log.Printf("Applied %d database migrations", result.TotalApplied)
	}

	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := routes.SetupRouter(cfg)

	port := cfg.Port
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
