package services

import (
	"cadence/models"
	"cadence/repositories"
)

type UserService struct {
	userRepo *repositories.UserRepository
}

func NewUserService(userRepo *repositories.UserRepository) *UserService {
	return &UserService{userRepo: userRepo}
}

// CreateUser creates a new user
func (s *UserService) CreateUser(userReq models.UserCreateRequest) (*models.UserResponse, error) {
	// TODO: Implement business logic for user creation
	return &models.UserResponse{}, nil
}

// GetUserByID retrieves a user by ID
func (s *UserService) GetUserByID(id string) (*models.UserResponse, error) {
	// TODO: Implement user retrieval logic
	return &models.UserResponse{}, nil
}

// GetUserByEmail retrieves a user by email
func (s *UserService) GetUserByEmail(email string) (*models.UserResponse, error) {
	// TODO: Implement user retrieval by email
	return &models.UserResponse{}, nil
}

// DeleteUser deletes the user and all associated data.
func (s *UserService) DeleteUser(userID string) error {
	return s.userRepo.DeleteUser(userID)
}
