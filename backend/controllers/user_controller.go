package controllers

import (
	"net/http"

	"cadence/middleware"
	"cadence/models"
	"cadence/services"

	"github.com/gin-gonic/gin"
)

type UserController struct {
	userService *services.UserService
}

func NewUserController(userService *services.UserService) *UserController {
	return &UserController{userService: userService}
}

// GetUsers returns a list of users
func (uc *UserController) GetUsers(c *gin.Context) {
	users := []models.UserResponse{}
	c.JSON(http.StatusOK, gin.H{
		"users": users,
		"count": len(users),
	})
}

// GetUser returns a single user by ID
func (uc *UserController) GetUser(c *gin.Context) {
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

// DeleteMe deletes the authenticated user and all their data, returning 204 on success.
func (uc *UserController) DeleteMe(c *gin.Context) {
	userID, exists := c.Get(middleware.UserIDKey)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	id, ok := userID.(string)
	if !ok || id == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	if err := uc.userService.DeleteUser(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete account"})
		return
	}

	c.Status(http.StatusNoContent)
}
