package controllers

import (
	"errors"
	"net/http"

	"cadence/services"

	"github.com/gin-gonic/gin"
)

type AuthController struct {
	authService *services.AuthService
}

func NewAuthController(authService *services.AuthService) *AuthController {
	return &AuthController{authService: authService}
}

type loginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type registerRequest struct {
	Email    string  `json:"email" binding:"required,email"`
	Password string  `json:"password" binding:"required"`
	Name     *string `json:"name,omitempty"`
}

func (ac *AuthController) Login(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "details": err.Error()})
		return
	}

	token, user, err := ac.authService.Login(req.Email, req.Password)
	if err != nil {
		if errors.Is(err, services.ErrInvalidCredentials) {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Login failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user":  user,
	})
}

func (ac *AuthController) Register(c *gin.Context) {
	var req registerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "details": err.Error()})
		return
	}

	token, user, err := ac.authService.Register(req.Email, req.Password, req.Name)
	if err != nil {
		if errors.Is(err, services.ErrEmailTaken) {
			c.JSON(http.StatusConflict, gin.H{"error": "Email already in use"})
			return
		}
		if errors.Is(err, services.ErrWeakPassword) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Password must be at least 8 characters"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Registration failed"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"token": token,
		"user":  user,
	})
}
