package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

const (
	rateLimitRequests = 10
	rateLimitWindow   = time.Minute
	cleanupInterval   = 5 * time.Minute
)

type windowEntry struct {
	timestamps []time.Time
	mu         sync.Mutex
}

type rateLimiter struct {
	clients map[string]*windowEntry
	mu      sync.RWMutex
}

func newRateLimiter() *rateLimiter {
	rl := &rateLimiter{
		clients: make(map[string]*windowEntry),
	}
	go rl.cleanup()
	return rl
}

func (rl *rateLimiter) cleanup() {
	ticker := time.NewTicker(cleanupInterval)
	defer ticker.Stop()
	for range ticker.C {
		now := time.Now()
		cutoff := now.Add(-rateLimitWindow)
		rl.mu.Lock()
		for ip, entry := range rl.clients {
			entry.mu.Lock()
			// Remove timestamps outside the window
			filtered := entry.timestamps[:0]
			for _, t := range entry.timestamps {
				if t.After(cutoff) {
					filtered = append(filtered, t)
				}
			}
			entry.timestamps = filtered
			// If no recent activity, remove the entry entirely
			if len(entry.timestamps) == 0 {
				delete(rl.clients, ip)
			}
			entry.mu.Unlock()
		}
		rl.mu.Unlock()
	}
}

func (rl *rateLimiter) allow(ip string) bool {
	now := time.Now()
	cutoff := now.Add(-rateLimitWindow)

	rl.mu.RLock()
	entry, exists := rl.clients[ip]
	rl.mu.RUnlock()

	if !exists {
		rl.mu.Lock()
		// Double-check after acquiring write lock
		entry, exists = rl.clients[ip]
		if !exists {
			entry = &windowEntry{}
			rl.clients[ip] = entry
		}
		rl.mu.Unlock()
	}

	entry.mu.Lock()
	defer entry.mu.Unlock()

	// Prune old timestamps
	filtered := entry.timestamps[:0]
	for _, t := range entry.timestamps {
		if t.After(cutoff) {
			filtered = append(filtered, t)
		}
	}
	entry.timestamps = filtered

	if len(entry.timestamps) >= rateLimitRequests {
		return false
	}

	entry.timestamps = append(entry.timestamps, now)
	return true
}

var defaultRateLimiter = newRateLimiter()

// AuthRateLimit limits auth endpoints to 10 requests per minute per IP.
func AuthRateLimit() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		if !defaultRateLimiter.allow(ip) {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "Too many requests. Please try again later.",
			})
			return
		}
		c.Next()
	}
}
