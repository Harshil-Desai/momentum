package config

import (
	"log"
	"time"

	"github.com/spf13/viper"
)

type Config struct {
	Port              string
	Environment       string
	DatabaseURL       string
	DBHost            string
	DBPort            string
	DBUser            string
	DBPassword        string
	DBName            string
	DBMaxOpenConns    int
	DBMaxIdleConns    int
	DBConnMaxLifetime time.Duration
	JWTSecret         string
	SentryDSN         string
}

func LoadConfig() *Config {
	viper.SetConfigFile(".env")
	viper.SetConfigType("env")
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	return &Config{
		Port:              viper.GetString("PORT"),
		Environment:       viper.GetString("ENVIRONMENT"),
		DatabaseURL:       viper.GetString("DATABASE_URL"),
		DBHost:            viper.GetString("DB_HOST"),
		DBPort:            viper.GetString("DB_PORT"),
		DBUser:            viper.GetString("DB_USER"),
		DBPassword:        viper.GetString("DB_PASSWORD"),
		DBName:            viper.GetString("DB_NAME"),
		DBMaxOpenConns:    viper.GetInt("DB_MAX_OPEN_CONNS"),
		DBMaxIdleConns:    viper.GetInt("DB_MAX_IDLE_CONNS"),
		DBConnMaxLifetime: viper.GetDuration("DB_CONN_MAX_LIFETIME"),
		JWTSecret:         viper.GetString("JWT_SECRET"),
		SentryDSN:         viper.GetString("SENTRY_DSN"),
	}
}
