package xendit

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

type Client struct {
	baseURL   string
	secretKey string
	hc        *http.Client
}

func NewClient(baseURL, secretKey string) *Client {
	baseURL = strings.TrimSpace(baseURL)
	if baseURL == "" {
		baseURL = "https://api.xendit.co"
	}
	return &Client{
		baseURL:   strings.TrimRight(baseURL, "/"),
		secretKey: strings.TrimSpace(secretKey),
		hc:        &http.Client{Timeout: 20 * time.Second},
	}
}

type CreateInvoiceRequest struct {
	ExternalID  string `json:"external_id"`
	Amount      int    `json:"amount"`
	PayerEmail  string `json:"payer_email,omitempty"`
	Description string `json:"description,omitempty"`
}

type CreateInvoiceResponse struct {
	ID         string `json:"id"`
	ExternalID string `json:"external_id"`
	Amount     int    `json:"amount"`
	Status     string `json:"status"`
	InvoiceURL string `json:"invoice_url"`
}

func (c *Client) CreateInvoice(ctx context.Context, req CreateInvoiceRequest) (CreateInvoiceResponse, []byte, error) {
	var zero CreateInvoiceResponse
	if c.secretKey == "" {
		return zero, nil, fmt.Errorf("XENDIT_SECRET_KEY is empty")
	}
	if strings.TrimSpace(req.ExternalID) == "" {
		return zero, nil, fmt.Errorf("external_id is required")
	}
	if req.Amount <= 0 {
		return zero, nil, fmt.Errorf("amount must be > 0")
	}

	bodyBytes, err := json.Marshal(req)
	if err != nil {
		return zero, nil, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/v2/invoices", bytes.NewReader(bodyBytes))
	if err != nil {
		return zero, nil, err
	}

	// Xendit API commonly uses Basic Auth with secret key.
	basic := base64.StdEncoding.EncodeToString([]byte(c.secretKey + ":"))
	httpReq.Header.Set("Authorization", "Basic "+basic)
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Accept", "application/json")

	resp, err := c.hc.Do(httpReq)
	if err != nil {
		return zero, nil, err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return zero, respBody, fmt.Errorf("xendit: unexpected status %d", resp.StatusCode)
	}

	var out CreateInvoiceResponse
	if err := json.Unmarshal(respBody, &out); err != nil {
		return zero, respBody, err
	}
	return out, respBody, nil
}
