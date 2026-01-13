package httpapi

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"pasar-lokal/backend/internal/xendit"
)

type CreateInvoiceInput struct {
	ExternalID  string `json:"external_id,omitempty"`
	Amount      int    `json:"amount"`
	PayerEmail  string `json:"payer_email,omitempty"`
	Description string `json:"description,omitempty"`
}

type CreateInvoiceOutput struct {
	PaymentID  string `json:"payment_id"`
	InvoiceID  string `json:"invoice_id"`
	ExternalID string `json:"external_id"`
	Amount     int    `json:"amount"`
	Status     string `json:"status"`
	InvoiceURL string `json:"invoice_url"`
}

func randID(prefix string) string {
	b := make([]byte, 12)
	_, _ = rand.Read(b)
	return prefix + hex.EncodeToString(b)
}

func (h *Handlers) CreateXenditInvoice(w http.ResponseWriter, r *http.Request) {
	if h.db == nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db not configured"})
		return
	}
	if strings.TrimSpace(h.cfg.XenditSecretKey) == "" {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "XENDIT_SECRET_KEY not configured"})
		return
	}

	var in CreateInvoiceInput
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "invalid json"})
		return
	}
	if in.Amount <= 0 {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "amount must be > 0"})
		return
	}

	externalID := strings.TrimSpace(in.ExternalID)
	if externalID == "" {
		externalID = "plk-" + time.Now().UTC().Format("20060102T150405Z") + "-" + randID("")
	}
	paymentID := randID("pay_")

	client := xendit.NewClient(h.cfg.XenditBaseURL, h.cfg.XenditSecretKey)
	inv, rawResp, err := client.CreateInvoice(r.Context(), xendit.CreateInvoiceRequest{
		ExternalID:  externalID,
		Amount:      in.Amount,
		PayerEmail:  strings.TrimSpace(in.PayerEmail),
		Description: strings.TrimSpace(in.Description),
	})
	if err != nil {
		w.WriteHeader(http.StatusBadGateway)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": err.Error(), "provider_response": string(rawResp)})
		return
	}

	status := inv.Status
	if strings.TrimSpace(status) == "" {
		status = "PENDING"
	}

	if err := insertPayment(
		r.Context(),
		h.db,
		paymentID,
		externalID,
		inv.ID,
		inv.InvoiceURL,
		in.Amount,
		status,
		rawResp,
	); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db insert failed"})
		return
	}

	_ = json.NewEncoder(w).Encode(CreateInvoiceOutput{
		PaymentID:  paymentID,
		InvoiceID:  inv.ID,
		ExternalID: externalID,
		Amount:     inv.Amount,
		Status:     status,
		InvoiceURL: inv.InvoiceURL,
	})
}

func insertPayment(ctx context.Context, db *pgxpool.Pool, id, externalID, invoiceID, invoiceURL string, amount int, status string, providerPayload []byte) error {
	_, err := db.Exec(ctx, `
		INSERT INTO payments (id, provider, external_id, invoice_id, invoice_url, amount, status, provider_payload)
		VALUES ($1, 'xendit_invoice', $2, $3, $4, $5, $6, $7)
	`, id, externalID, invoiceID, invoiceURL, amount, status, providerPayload)
	return err
}
