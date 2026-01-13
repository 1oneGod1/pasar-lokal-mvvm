-- Dev-only migration

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS invoice_url TEXT;
