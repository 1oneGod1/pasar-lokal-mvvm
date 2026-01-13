# Usability Test Plan (Basic)

## Goal

Menilai apakah pengguna baru dapat menyelesaikan tugas inti (login, eksplorasi produk, keranjang, pesanan, navigasi tab) dengan **mudah, cepat, dan minim kebingungan**.

## Participants

Minimal **3 orang**.

**Kriteria disarankan**:

- Pernah memakai aplikasi e-commerce (Shopee/Tokopedia/dll)
- Belum pernah memakai Pasar Lokal MVVM
- Variasi: 1 orang sangat familiar, 1 orang sedang, 1 orang jarang belanja online (opsional)

**Rekrutmen cepat**:

- Teman kampus/keluarga (minta 10–15 menit)

## Setup

- Device: Android / emulator (atau web jika terpaksa)
- Catatan: gunakan **screen recording** jika memungkinkan
- Siapkan akun demo (lihat README)

## Method

- **Moderated usability test** (Anda mendampingi)
- Teknik: **Think-aloud** (peserta mengucapkan apa yang dipikirkan)

## Tasks / Scenarios

Tulis “sukses/gagal”, waktu, dan catatan error setiap tugas.

1. **Login pembeli** (pakai akun demo)
   - Target: masuk ke Beranda
2. **Cari produk**
   - Target: menemukan produk tertentu dari list (contoh: “Madu Hutan”) atau minimal membuka 1 detail produk
3. **Tambah ke keranjang**
   - Target: 1 produk masuk keranjang, quantity bisa diubah
4. **Lihat keranjang & total**
   - Target: peserta paham total harga & item
5. **Checkout**
   - Target: membuat pesanan (jika flow ada)
6. **Navigasi tab**
   - Target: pindah ke `Peta` lalu ke `Pesanan`, kembali ke `Beranda`

## Data to Collect

- Observasi: kesalahan klik, kebingungan, ragu-ragu, tombol tidak terlihat
- Waktu (perkiraan) per tugas
- Komentar think-aloud

## Post-Test Questions (5–7 menit)

Skala 1–5 (1 sangat tidak setuju, 5 sangat setuju):

1. Saya mudah memahami navigasi aplikasi.
2. Saya mudah menemukan produk.
3. Proses keranjang/checkout jelas.
4. Tampilan aplikasi nyaman dibaca.

Pertanyaan terbuka:

- Bagian mana yang paling membingungkan?
- 1 hal yang paling Anda suka?
- Jika bisa memperbaiki 1 hal, apa itu?

## Success Criteria (basic)

- Minimal 4 dari 6 tugas terselesaikan tanpa bantuan
- Masalah utama terkumpul dan ada minimal 1–2 perbaikan yang diterapkan
