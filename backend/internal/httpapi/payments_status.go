package httpapi

import (
	"encoding/json"
	"net/http"
)

type GetPaymentOutput struct {
	PaymentID  string `json:"payment_id"`
	InvoiceID  string `json:"invoice_id"`
	ExternalID string `json:"external_id"`
	Amount     int    `json:"amount"`
	Status     string `json:"status"`
	InvoiceURL string `json:"invoice_url"`
}

func (h *Handlers) GetPaymentByExternalID(w http.ResponseWriter, r *http.Request) {
	if h.db == nil {
		w.WriteHeader(http.StatusServiceUnavailable)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db not configured"})
		return
	}

	externalID := r.PathValue("externalId")
	out, ok, err := getPaymentByExternalID(r.Context(), h.db, externalID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "db query failed"})
		return
	}
	if !ok {
		w.WriteHeader(http.StatusNotFound)
		_ = json.NewEncoder(w).Encode(map[string]any{"ok": false, "error": "payment not found"})
		return
	}

	_ = json.NewEncoder(w).Encode(out)
}
