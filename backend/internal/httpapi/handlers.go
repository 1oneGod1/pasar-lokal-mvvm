package httpapi

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"

	"pasar-lokal/backend/internal/config"
	"pasar-lokal/backend/internal/xendit"
)

type Handlers struct {
	cfg    config.Config
	logger *log.Logger
	db     *pgxpool.Pool
}

func NewHandlers(cfg config.Config, logger *log.Logger, dbPool *pgxpool.Pool) *Handlers {
	return &Handlers{cfg: cfg, logger: logger, db: dbPool}
}

func (h *Handlers) Healthz(w http.ResponseWriter, r *http.Request) {
	_ = json.NewEncoder(w).Encode(map[string]any{"ok": true})
}

type Product struct {
	ID    string  `json:"id"`
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

func (h *Handlers) ListProducts(w http.ResponseWriter, r *http.Request) {
	if h.db == nil {
		// Keep a safe fallback for local runs without DB.
		products := []Product{
			{ID: "prod-mango", Name: "Manis Medan Mango", Price: 25000},
			{ID: "prod-coffee", Name: "Lintong Coffee Beans", Price: 78000},
		}
		_ = json.NewEncoder(w).Encode(map[string]any{"data": products})
		return
	}

	rows, err := h.db.Query(r.Context(), `SELECT id, name, price FROM products ORDER BY created_at DESC LIMIT 50`)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db query failed"})
		return
	}
	defer rows.Close()

	products := make([]Product, 0, 50)
	for rows.Next() {
		var id, name string
		var price int
		if err := rows.Scan(&id, &name, &price); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db scan failed"})
			return
		}
		products = append(products, Product{ID: id, Name: name, Price: float64(price)})
	}
	if err := rows.Err(); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db rows failed"})
		return
	}

	_ = json.NewEncoder(w).Encode(map[string]any{"data": products})
}

func (h *Handlers) XenditWebhook(w http.ResponseWriter, r *http.Request) {
	payload, _ := io.ReadAll(r.Body)
	defer r.Body.Close()

	// NOTE: Header name and verification rules depend on Xendit product (Invoice, Payment Method, etc.).
	// We keep this as a safe stub first: optional callback token check + log payload.
	if err := xendit.VerifyCallbackToken(r.Header, h.cfg.XenditCallbackToken); err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": err.Error()})
		return
	}

	h.logger.Printf("xendit webhook: %s", string(payload))
	if h.db != nil {
		// Best-effort: try to update payment status for Invoice events.
		var evt struct {
			ID     string `json:"id"`
			Status string `json:"status"`
		}
		if err := json.Unmarshal(payload, &evt); err == nil {
			invoiceID := strings.TrimSpace(evt.ID)
			status := strings.TrimSpace(evt.Status)
			if invoiceID != "" && status != "" {
				_ = updatePaymentByInvoiceID(r.Context(), h.db, invoiceID, status, payload)
			}
		}
	}
	_ = json.NewEncoder(w).Encode(map[string]any{"ok": true})
}
