package httpapi

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func getPaymentByExternalID(ctx context.Context, db *pgxpool.Pool, externalID string) (GetPaymentOutput, bool, error) {
	var out GetPaymentOutput
	row := db.QueryRow(ctx, `
		SELECT id, external_id, invoice_id, amount, status, COALESCE(invoice_url, '')
		FROM payments
		WHERE external_id = $1
		ORDER BY created_at DESC
		LIMIT 1
	`, externalID)

	if err := row.Scan(&out.PaymentID, &out.ExternalID, &out.InvoiceID, &out.Amount, &out.Status, &out.InvoiceURL); err != nil {
		if err == pgx.ErrNoRows {
			return GetPaymentOutput{}, false, nil
		}
		return GetPaymentOutput{}, false, err
	}
	return out, true, nil
}
