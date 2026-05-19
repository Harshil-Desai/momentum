package controllers

import (
	"net/http"

	"cadence/middleware"
	"cadence/models"

	"github.com/gin-gonic/gin"
)

type UserController struct {
	// Will be injected with UserService
}

// GetUsers returns a list of users
func (uc *UserController) GetUsers(c *gin.Context) {
	// TODO: Implement user retrieval logic
	users := []models.UserResponse{}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
		"count": len(users),
	})
}

// GetUser returns a single user by ID
func (uc *UserController) GetUser(c *gin.Context) {
	// TODO: Implement single user retrieval
	c.JSON(http.StatusOK, gin.H{
		"message": "Get user endpoint - to be implemented",
	})
}

// CreateUser creates a new user
func (uc *UserController) CreateUser(c *gin.Context) {
	var userReq models.UserCreateRequest

	if err := c.ShouldBindJSON(&userReq); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	if err := middleware.Validator().Struct(userReq); err != nil {
		c.JSON(http.StatusUnprocessableEntity, gin.H{
			"error":   "Validation failed",
			"details": err.Error(),
		})
		return
	}

	// TODO: Implement user creation logic
	c.JSON(http.StatusCreated, gin.H{
		"message": "User created successfully",
	})
}
