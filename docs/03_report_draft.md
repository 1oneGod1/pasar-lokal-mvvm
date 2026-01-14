# Pasar Lokal MVVM — Brief Report (2–3 pages)

## 1) Purpose & Problem Statement

Pasar Lokal MVVM adalah prototipe marketplace berbasis Flutter yang bertujuan membantu pengguna menemukan dan membeli produk lokal secara cepat, sekaligus memberi tampilan dashboard sederhana untuk penjual.

**Problem / Need (ringkas):**

- [Isi 2–3 kalimat masalah yang kamu temukan + bagaimana aplikasi ini membantu]

**Target pengguna**:

- Pembeli yang ingin eksplorasi produk lokal + checkout
- Penjual yang ingin memantau KPI/pesanan (demo)

## 2) Core Features Implemented

Fitur inti yang diselesaikan:

- Auth demo: login pembeli/penjual, register, Google sign-in (demo)
- Browse produk: daftar produk + detail
- Keranjang: tambah, ubah quantity, hapus, hitung total
- Pesanan: checkout menjadi order + lihat daftar pesanan
- Navigasi: bottom navigation Beranda/Peta/Pesanan/Akun
- Peta: menampilkan penjual terdekat berbasis OpenStreetMap

## 3) Design & Development Process

### Design principles

- **Separation of Concerns**: UI dipisah dari logika bisnis dan akses data.
- **Single Responsibility**: repository fokus data, viewmodel fokus state & aturan, views fokus render.

### Pattern: MVVM

- **Models**: entitas di `lib/core/models`
- **Repositories**: sumber data di `lib/core/repositories` (sebagian memanfaatkan `LocalStore`/Hive)
- **ViewModels**: `ChangeNotifier` di `lib/features/**/viewmodels`
- **Views**: layar di `lib/features/**/views` yang membaca state via `provider`

## 4) Decoupling & Modularization

- Wiring dependensi terpusat di `lib/main.dart` dengan `MultiProvider`.
- Views tidak mengakses repository secara langsung; interaksi dilakukan lewat ViewModel.
- Contoh decoupling navigasi tab: `HomeTabScope` menyediakan callback pilih tab tanpa coupling antar widget.

## 5) Usability Testing

### Method

Basic moderated usability test + think-aloud.

### Participants

3 orang pengguna baru (lihat detail pada file hasil).

Ringkas profil peserta (contoh):

- P1: [role/umur/kebiasaan]
- P2: [role/umur/kebiasaan]
- P3: [role/umur/kebiasaan]

### Tasks

Login, cari produk, tambah keranjang, lihat keranjang, checkout, navigasi tab.

### Results

Ringkasan hasil ada di `docs/02_usability_test_results.md`.

**Temuan utama (contoh, sesuaikan):**

- Search kurang menonjol → user butuh bantuan
- Navigasi tab mudah dipahami

### Improvements Applied

- Perubahan 1: [temuan → perubahan] (sertakan screenshot jika ada)
- Perubahan 2: [temuan → perubahan]

Catatan: minimal 1–2 perbaikan setelah testing agar memenuhi requirement “adjustments based on feedback”.

## 6) Challenges

- [Contoh] Menjaga konsistensi state antar halaman
- [Contoh] Membuat flow checkout tetap sederhana tapi realistis

## 7) Repository & Screenshots

- Source code: [ISI_LINK_REPO_DI_SINI]
- Screenshots: taruh di folder `docs/screenshots/` (contoh nama file ada di `docs/screenshots/README.md`)

## How to export to PDF

- VS Code: install extension “Markdown PDF” lalu export `docs/03_report_draft.md` ke PDF
- Alternatif: Print to PDF dari preview Markdown
