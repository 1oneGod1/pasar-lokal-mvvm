package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"pasar-lokal/backend/internal/config"
	"pasar-lokal/backend/internal/db"
	"pasar-lokal/backend/internal/httpapi"
)

func main() {
	cfg := config.LoadFromEnv()
	logger := log.New(os.Stdout, "", log.LstdFlags|log.LUTC)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	var poolCloser func()
	var dbPool *pgxpool.Pool
	if cfg.DatabaseURL != "" {
		p, err := db.Open(ctx, cfg.DatabaseURL)
		if err != nil {
			logger.Fatalf("db open: %v", err)
		}
		dbPool = p
		poolCloser = func() { p.Close() }
	} else {
		logger.Printf("DATABASE_URL empty; running without DB")
	}

	mux := http.NewServeMux()
	h := httpapi.NewHandlers(cfg, logger, dbPool)

	mux.HandleFunc("GET /healthz", h.Healthz)
	mux.HandleFunc("GET /v1/products", h.ListProducts)
	mux.HandleFunc("POST /v1/payments/xendit/invoices", h.CreateXenditInvoice)
	mux.HandleFunc("GET /v1/payments/external/{externalId}", h.GetPaymentByExternalID)
	mux.HandleFunc("POST /v1/payments/xendit/webhook", h.XenditWebhook)

	appHandler := httpapi.WithMiddleware(mux, logger)

	srv := &http.Server{
		Addr:              cfg.HTTPAddr(),
		Handler:           appHandler,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	go func() {
		logger.Printf("api listening on %s", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("listen: %v", err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdownCtx)
	if poolCloser != nil {
		poolCloser()
	}
	logger.Printf("shutdown complete")
}
