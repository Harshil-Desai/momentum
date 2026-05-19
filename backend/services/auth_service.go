package services

import (
	"errors"
	"fmt"
	"time"

	"cadence/models"
	"cadence/repositories"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrUserNotFound       = errors.New("user not found")
	ErrEmailTaken         = errors.New("email already in use")
	ErrWeakPassword       = errors.New("password must be at least 8 characters")
)

type Claims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

type AuthService struct {
	userRepo  *repositories.UserRepository
	jwtSecret string
}

func NewAuthService(userRepo *repositories.UserRepository, jwtSecret string) *AuthService {
	return &AuthService{userRepo: userRepo, jwtSecret: jwtSecret}
}

func (s *AuthService) Login(email, password string) (string, *models.UserResponse, error) {
	user, err := s.userRepo.FindByEmail(email)
	if err != nil {
		return "", nil, fmt.Errorf("looking up user: %w", err)
	}
	if user == nil {
		return "", nil, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return "", nil, ErrInvalidCredentials
	}

	token, err := s.generateToken(user)
	if err != nil {
		return "", nil, fmt.Errorf("generating token: %w", err)
	}

	return token, user.ToResponse(), nil
}

func (s *AuthService) Register(email, password string, name *string) (string, *models.UserResponse, error) {
	if len(password) < 8 {
		return "", nil, ErrWeakPassword
	}

	exists, err := s.userRepo.ExistsByEmail(email)
	if err != nil {
		return "", nil, fmt.Errorf("checking email: %w", err)
	}
	if exists {
		return "", nil, ErrEmailTaken
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", nil, fmt.Errorf("hashing password: %w", err)
	}

	user := &models.User{
		Email:        email,
		PasswordHash: string(hash),
		Name:         name,
	}
	if err := s.userRepo.Create(user); err != nil {
		return "", nil, fmt.Errorf("creating user: %w", err)
	}

	token, err := s.generateToken(user)
	if err != nil {
		return "", nil, fmt.Errorf("generating token: %w", err)
	}

	return token, user.ToResponse(), nil
}

func (s *AuthService) ValidateToken(tokenStr string) (*Claims, error) {
	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.jwtSecret), nil
	})
	if err != nil || !token.Valid {
		return nil, errors.New("invalid or expired token")
	}
	return claims, nil
}

func (s *AuthService) generateToken(user *models.User) (string, error) {
	claims := &Claims{
		UserID: user.ID,
		Email:  user.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(30 * 24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   user.ID,
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}
