package httpapi

import (
	"log"
	"net/http"
	"time"
)

func WithMiddleware(next http.Handler, logger *log.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		w.Header().Set("Content-Type", "application/json; charset=utf-8")

		next.ServeHTTP(w, r)

		logger.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
	})
}
