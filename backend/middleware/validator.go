package middleware

import (
	"sync"

	"github.com/go-playground/validator/v10"
)

var (
	validate *validator.Validate
	once     sync.Once
)

func Validator() *validator.Validate {
	once.Do(func() {
		validate = validator.New()
	})
	return validate
}
