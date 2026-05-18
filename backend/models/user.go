package models

import (
	"time"
)

// User represents a user in the system
type User struct {
	ID           string     `json:"id" db:"id"`
	Email        string     `json:"email" db:"email"`
	PasswordHash string     `json:"-" db:"password_hash"` // Hidden from JSON
	PushToken    *string    `json:"push_token,omitempty" db:"push_token"` // Nullable
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at" db:"updated_at"`
}

// UserCreateRequest represents the request for creating a user
type UserCreateRequest struct {
	Email    string `json:"email" binding:"required,email" validate:"required,email"`
	Password string `json:"password" binding:"required,min=6" validate:"required,min=6"`
}

// UserLoginRequest represents the request for user login
type UserLoginRequest struct {
	Email    string `json:"email" binding:"required,email" validate:"required,email"`
	Password string `json:"password" binding:"required" validate:"required"`
}

// UserResponse represents the user data returned in responses
type UserResponse struct {
	ID        string    `json:"id"`
	Email     string    `json:"email"`
	PushToken *string   `json:"push_token,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// UserUpdateRequest represents the request for updating a user
type UserUpdateRequest struct {
	Email     *string `json:"email,omitempty" binding:"omitempty,email" validate:"omitempty,email"`
	PushToken *string `json:"push_token,omitempty"`
}

// UserWithHabits represents a user with their habits (for joined queries)
type UserWithHabits struct {
	User
	Habits []Habit `json:"habits,omitempty"`
}

// ToResponse converts a User to UserResponse
func (u *User) ToResponse() *UserResponse {
	return &UserResponse{
		ID:        u.ID,
		Email:     u.Email,
		PushToken: u.PushToken,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}
}

// TableName returns the database table name for the User model
func (User) TableName() string {
	return "users"
}