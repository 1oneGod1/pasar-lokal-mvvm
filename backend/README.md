# PasarLokal Backend (Go)

Minimal Go API untuk PasarLokal (Android) + stub webhook Xendit.

## Run (lokal)

### Opsi 1: Docker Compose

Opsional: siapkan env (kalau mau override default):

```powershell
Set-Location .\backend
Copy-Item .env.example .env
```

```bash
docker compose up --build
```

- API: `http://localhost:8080`
- Health: `GET /healthz`
- Products: `GET /v1/products`
- Create Xendit invoice: `POST /v1/payments/xendit/invoices`
- Xendit webhook (stub): `POST /v1/payments/xendit/webhook`

Kalau port `8080` bentrok di Windows, set `PORT=8081` (di `.env` atau env shell) lalu jalankan lagi.

### Opsi 2: Go langsung

```bash
go run ./cmd/api
```

Kalau di Windows port `8080` error (mis. _access permissions_), gunakan port lain, contoh:

```powershell
Set-Location .\backend
$env:PORT=8081
go run .\cmd\api
```

Env vars:

- `PORT` (default `8080`)
- `DATABASE_URL` (jika kosong, API tetap jalan tapi `/v1/products` pakai fallback)
- `XENDIT_CALLBACK_TOKEN` (opsional; jika di-set akan memvalidasi header callback token)
- `XENDIT_SECRET_KEY` (wajib untuk create invoice)
- `XENDIT_BASE_URL` (opsional)

## Database & migrations

Untuk dev via Docker, file SQL di `migrations/` akan dijalankan otomatis oleh container Postgres saat pertama kali volume database dibuat.

## Catatan Xendit

Header & payload webhook berbeda tergantung produk Xendit (Invoices, Payment Method, dll). Endpoint ini masih stub aman untuk tahap awal.
