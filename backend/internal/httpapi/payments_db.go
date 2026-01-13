package httpapi

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

func updatePaymentByInvoiceID(ctx context.Context, db *pgxpool.Pool, invoiceID string, status string, webhookPayload []byte) error {
	_, err := db.Exec(ctx, `
		UPDATE payments
		SET status = $2,
		    webhook_payload = $3::jsonb,
		    updated_at = now()
		WHERE invoice_id = $1
	`, invoiceID, status, string(webhookPayload))
	return err
}
