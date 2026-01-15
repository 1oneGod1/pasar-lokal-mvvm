# Pasar Lokal MVVM — Brief Report (Ringkas)

## 1) Purpose & Problem Statement

Pasar Lokal MVVM adalah prototipe marketplace Flutter untuk membantu pembeli menemukan produk lokal dan memberi dashboard sederhana bagi penjual.

**Problem / Need (ringkas):** Pengguna membutuhkan pengalaman belanja lokal yang cepat, sederhana, dan mudah dinavigasi. Aplikasi ini menyediakan eksplorasi produk, keranjang, checkout, dan pemantauan pesanan dalam satu alur.

**Target pengguna:** pembeli yang ingin belanja produk lokal dan penjual yang memantau katalog/pesanan (demo).

## 2) Core Features Implemented

Fitur inti:

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

1 peserta (pembeli). Keterbatasan: waktu pengumpulan, belum sempat menambah peserta lain.

### Tasks

Login, cari produk, tambah keranjang, lihat keranjang, checkout, navigasi tab.

### Results

Ringkasan hasil ada di `docs/02_usability_test_results.md`.

**Temuan utama:**

- Desain UI masih kurang rapi menurut peserta.
- Login Google sempat error.
- Pesanan setelah checkout tidak bisa diedit.
- Peta belum real-time.

### Improvements Applied

- Perbaikan alur tambah produk (bottom sheet) agar tidak error saat simpan.
- Navigasi katalog penjual ditambahkan dari halaman Akun.

Catatan: minimal 1–2 perbaikan setelah testing agar memenuhi requirement “adjustments based on feedback”.

## 6) Challenges

- Menjaga konsistensi state antar halaman (beranda, pesanan, profil).
- Menjaga alur checkout tetap sederhana namun realistis.

## 7) Repository & Screenshots

- Source code: [ISI_LINK_REPO_DI_SINI]
- Screenshots: taruh di folder `docs/screenshots/` (contoh nama file ada di `docs/screenshots/README.md`)

## How to export to PDF

- VS Code: install extension “Markdown PDF” lalu export `docs/03_report_draft.md` ke PDF
- Alternatif: Print to PDF dari preview Markdown
