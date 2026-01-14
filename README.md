# Pasar Lokal MVVM

Pasar Lokal MVVM adalah prototipe marketplace lingkungan berbasis Flutter 3.7 yang menerapkan pola **Model–View–ViewModel (MVVM)** dari hulu ke hilir. Proyek ini memperlihatkan bagaimana memisahkan tampilan, logika domain, dan akses data sambil menyajikan pengalaman pembeli dan penjual dalam satu codebase.

## Objective (sesuai tugas)

Mengembangkan aplikasi mobile sederhana namun fungsional yang menjawab kebutuhan: **membantu pembeli menemukan dan membeli produk lokal dengan cepat** (aliran inti buyer), dengan menerapkan:

- prinsip desain dasar (separation of concerns, single responsibility)
- pola arsitektur sederhana (MVVM)
- usability testing dasar (≥ 3 user)
- decoupling tingkat awal (UI terpisah dari logika bisnis)

## Problem / Need

Pembeli sering kesulitan menemukan produk lokal terdekat/terpercaya dengan cepat. Aplikasi ini menyediakan prototipe katalog produk lokal, keranjang, checkout, dan riwayat pesanan dalam satu flow sederhana.

## Sorotan Fitur

- Antarmuka **Material 3** dengan tema **hijau** (seed color) dan navigasi bawah (`Beranda`, `Peta`, `Pesanan`, `Akun`).
- **Alur pembeli** mencakup eksplorasi produk, pengelolaan keranjang, checkout, dan pelacakan pesanan.
- **Dashboard penjual** menampilkan KPI toko, ringkasan stok, serta pipeline pesanan saat login sebagai penjual.
- **Tab peta** menggunakan [`flutter_map`](https://pub.dev/packages/flutter_map) + OpenStreetMap untuk memvisualisasikan penjual terdekat.
- **Lapisan MVVM yang dapat digunakan ulang** (model, repository, viewmodel) dengan `provider` untuk injeksi dependensi dan pembaruan state.
- Auth demo: **Login pembeli/penjual**, **Daftar (register)**, dan **Masuk dengan Google (demo/non-Firebase)**.

## Core Scope (yang dinilai / fokus 2 minggu)

Fokus implementasi (core) dibuat agar bisa selesai dan dites dalam waktu singkat:

1. Login demo (pembeli) → masuk aplikasi
2. Browse produk → buka detail
3. Tambah ke keranjang → ubah quantity/hapus → total terhitung
4. Checkout → terbentuk order
5. Lihat daftar pesanan

Fitur lain seperti dashboard penjual, peta, dan integrasi pembayaran bersifat pendukung/demo dan bisa diperlakukan sebagai nilai tambah.

## Ringkasan Arsitektur

| Lapisan          | Deskripsi                                                                                                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Models**       | Objek Dart sederhana di `lib/core/models` mendeskripsikan entitas seperti `Product`, `Order`, `MapLocation`, dan `User` (dengan peran pembeli/penjual).                      |
| **Repositories** | Penyimpanan in-memory di `lib/core/repositories` memuat data contoh dan logika CRUD. Dapat diganti dengan API atau basis data nyata.                                         |
| **ViewModels**   | Kelas `ChangeNotifier` di `lib/features/**/viewmodels` menerjemahkan data repository menjadi state siap pakai, mengekspose aturan bisnis, serta mengoordinasikan alur fitur. |
| **Views**        | Layar dan widget Material 3 di `lib/features/**/views` berlangganan provider dan merender UI reaktif.                                                                        |

### Struktur Proyek

```
lib/
  core/
	 models/            // Entitas (Product, Order, User, MapLocation, ...)
	 repositories/      // Sumber data in-memory (auth, products, orders, ...)
  features/
	 auth/              // Layar login + AuthViewModel
	 cart/
	 categories/
	 dashboard/         // Dashboard pembeli & penjual
	 map/
	 orders/
	 products/
	 profile/
	 sellers/
  main.dart            // Bootstrap MultiProvider + auth gate + navigasi
```

### Arsitektur “Decoupled / Headless” (Disesuaikan)

Di project ini, **UI (Views)** dibuat _tidak bergantung pada sumber data spesifik_. UI hanya membaca state + memicu aksi lewat **ViewModel**, sementara detail data ada di **Repository**.

- **Wiring dependensi ada di satu tempat:** `lib/main.dart` memakai `MultiProvider` untuk membuat viewmodel + repository, misalnya `AuthViewModel(AuthRepository())`, `CartViewModel(CartRepository())`, `ProductViewModel(ProductRepository())`, `OrderViewModel(OrderRepository())`, `MapViewModel(MapRepository())`.
- **UI hanya bicara ke ViewModel:** contoh alur keranjang, UI memanggil method di `CartViewModel` (`addToCart`, `incrementQuantity`, `checkout`) tanpa tahu apakah data keranjang disimpan di memori, database, atau API.
- **Repository bersifat “headless” (tanpa UI):** repository/viewmodel bisa dijalankan dan diuji tanpa widget. Contoh nyatanya ada pada unit test `test/cart_repository_test.dart` yang menguji `CartRepository` langsung (total, merge item, remove saat qty=0).

Kalau nanti ingin mengganti data in-memory menjadi API/DB:

- Titik perubahan utama ada di `lib/core/repositories/*` (implementasi sumber data) dan **wiring** di `lib/main.dart`.
- **Views** di `lib/features/**/views` idealnya tidak perlu berubah karena tetap berinteraksi lewat ViewModel.

## Akun Demo Pembeli & Penjual

Kredensial demo tersimpan di `AuthRepository`.

| Peran   | Email                        | Kata sandi   | Catatan                                              |
| ------- | ---------------------------- | ------------ | ---------------------------------------------------- |
| Pembeli | `andi@example.com`           | `rahasia123` | Sudah terisi di form login.                          |
| Pembeli | `sari@example.com`           | `belanja123` | Pakai tombol demo untuk mengisi otomatis.            |
| Penjual | `putri.seller@pasarlokal.id` | `spicehouse` | Mengakses dashboard penjual milik Putri Spice House. |

Memilih akun demo di layar login akan mengisi kredensial dan langsung mencoba masuk.

## Menjalankan Aplikasi

1. Pasang Flutter **3.7.2** atau yang lebih baru lalu tambahkan ke `PATH`.
2. Ambil seluruh paket:
   ```bash
   flutter pub get
   ```
3. Jalankan di Chrome (web) atau perangkat/emulator lain:
   ```bash
   flutter run -d chrome
   ```

### Backend (opsional)

Project ini memiliki backend Go (folder `backend/`) untuk endpoint pembayaran dan contoh API.

- Untuk menjalankan backend, lihat panduan di `backend/README.md`.
- Untuk mengarahkan app ke backend tertentu, set base URL:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

## Pengujian

Untuk AFL 3 (Unit & Widget Testing), project ini menyediakan (dan sudah dapat dijalankan):

- **Unit test** untuk logika keranjang di `test/cart_repository_test.dart`.
  - **Logika yang diuji (isolated/testable):** `CartRepository` menghitung total, menggabungkan item duplikat (quantity bertambah), dan menghapus item saat quantity = 0.
  - **Pola Arrange–Act–Assert:**
    - Arrange: membuat `CartRepository` + data `Product`.
    - Act: memanggil `addItem()` / `updateQuantity()`.
    - Assert: memverifikasi `items`, `quantity`, dan `total` dengan `expect(...)`.
- **Widget test** untuk alur login pembeli & penjual di `test/widget_test.dart`.
  - Menguji tampilan login muncul pertama, tombol `Masuk` membawa user ke beranda, dan akun demo penjual membuka dashboard penjual.

Semua test bisa dijalankan dengan perintah:

```bash
flutter test
```

### Detail AFL 3 (Unit & Widget Testing)

Bagian ini ditulis untuk memenuhi instruksi AFL 3: memilih satu fitur yang bisa diuji, menentukan logic yang bisa dites secara terisolasi, lalu menulis unit test dan (opsional) widget test.

#### 1) Feature yang dipilih

**Keranjang belanja (Cart)**.

Di aplikasi ini, keranjang dipakai untuk menampung produk sebelum checkout, menghitung total, mengubah quantity, dan menghasilkan `Order` saat checkout.

**Akses UI keranjang:** ikon keranjang + badge jumlah item tersedia di Beranda (header) dan di Detail Produk.

#### 2) Testable logic (yang bisa diuji terisolasi)

Logic yang dites berada pada lapisan data (in-memory) di `lib/core/repositories/cart_repository.dart` (dibungkus oleh `CartViewModel`).

Alasan cocok untuk unit test:

- Tidak perlu UI untuk membuktikan perilakunya.
- Input/aksi jelas (`addItem`, `updateQuantity`) dan output/state jelas (`items`, `total`).

#### 3) Unit test yang dibuat

**File:** `test/cart_repository_test.dart`

Test cases yang ada (beserta Arrange–Act–Assert):

1. **calculates total and merges duplicate items**

- Arrange: buat `CartRepository` + 1 `Product`.
- Act: panggil `addItem(product)` dua kali.
- Assert: `items.length == 1`, quantity jadi 2, dan `total == price * 2`.

2. **removes item when quantity set to zero**

- Arrange: buat repo + tambah 1 item.
- Act: panggil `updateQuantity(cartItemId, 0)`.
- Assert: `items` kosong dan `total == 0`.

3. **sums totals across multiple products**

- Arrange: buat repo + dua `Product` dengan harga berbeda.
- Act: tambah A sekali, tambah B dua kali.
- Assert: `total` sama dengan penjumlahan semua subtotal.

#### 4) Widget test (tambahan)

**File:** `test/widget_test.dart`

Widget test yang ada membantu membuktikan flow UI utama:

- Layar login tampil pertama.
- Tombol `Masuk` login sebagai pembeli dan aplikasi merender beranda + bottom nav.
- Akun demo penjual bisa login dan masuk ke dashboard penjual.

#### 5) Cara menjalankan

```bash
flutter test
```

> ℹ️ Tab peta memakai ubin OpenStreetMap. Hindari trafik berlebihan pada server publik.

## Dokumentasi (AFL)

Template dan draft laporan untuk memenuhi requirement usability testing dan report disediakan di folder `docs/`:

- `docs/00_project_scope.md` — scope, fitur inti, definition of done
- `docs/01_usability_test_plan.md` — rencana test (3 user) + skenario + pertanyaan
- `docs/02_usability_test_results.md` — template hasil (P1–P3) + ringkasan temuan + perbaikan
- `docs/03_report_draft.md` — draft report 2–3 halaman (siap diekspor ke PDF)

Untuk ekspor ke PDF, gunakan VS Code extension “Markdown PDF” atau Print to PDF dari preview Markdown.

## Usability Testing (≥ 3 users)

Usability test dasar dilakukan dengan metode moderated + think-aloud.

- Plan: `docs/01_usability_test_plan.md`
- Results (isi 3 peserta): `docs/02_usability_test_results.md`

Ringkasan yang perlu ada agar sesuai rubric:

- minimal 3 peserta (P1–P3)
- 5–6 task inti (login, cari/buka produk, add cart, lihat cart, checkout, navigasi)
- catatan success/help/time + temuan utama
- daftar perbaikan yang diterapkan setelah test (mapping temuan → perubahan)

### Update Berdasarkan Refleksi AFL1 (Pilot)

Berdasarkan laporan refleksi usability testing AFL1 (moderated + think-aloud), beberapa temuan kunci dan update yang sudah tercermin di aplikasi ini:

- **Form register lebih jelas**: field konfirmasi password sudah diberi label **"Konfirmasi kata sandi"** dan hint **"Ulangi kata sandi"**.
- **Fitur pencarian lebih terlihat**: halaman beranda menyediakan **search field** yang menonjol (bukan hanya ikon kecil), dengan hint teks dan ikon search.
- **Navigasi tab bawah intuitif**: perpindahan antar tab utama dinilai mudah dipahami (mengikuti pola umum aplikasi mobile).

Catatan: AFL1 pada laporan refleksi menggunakan 1 partisipan (pilot). Untuk memenuhi requirement tugas, lanjutkan usability test sampai ≥3 partisipan dan isi hasil final di `docs/02_usability_test_results.md`.

## Submission Checklist

- Report 2–3 halaman: `docs/03_report_draft.md` (export ke PDF)
- Screenshot aplikasi: taruh di `docs/screenshots/` (lihat `docs/screenshots/README.md`)
- Link repository source code: [ISI_LINK_REPO_DI_SINI]

## Catatan & Pengembangan Lanjutan

Bagian ini merangkum area pengembangan ke depan sekaligus kendala teknis yang perlu diantisipasi.

### Prioritas Perbaikan (Roadmap Singkat)

#### P0 (wajib dibereskan supaya alur inti aman)

- **Checkout yang “transaksional”**
  - Saat ini alur checkout membuat `Order` dulu lalu membuat invoice. Jika create invoice gagal, order sudah terlanjur tersimpan.
  - Opsi perbaikan:
    - Buat order berstatus `UNPAID/PENDING_PAYMENT` lalu update saat pembayaran sukses (via webhook/polling), atau
    - Buat invoice dulu, baru commit order saat invoice sukses.
- **Cegah double checkout**
  - Tombol checkout perlu di-disable ketika request invoice sedang berjalan (gunakan state loading di `PaymentViewModel`) untuk mencegah double-tap / duplicate invoice.

#### P1 (meningkatkan maintainability & kualitas UX)

- **Pindahkan orkestrasi checkout dari View ke ViewModel/UseCase**
  - Agar UI “tipis”, logic mudah dites, dan penanganan error konsisten.
- **Perkuat error handling network**
  - `ApiClient` mengasumsikan response selalu JSON Map; jika backend mengembalikan non-JSON (mis. 502 HTML), akan muncul `FormatException`.
  - Tambahkan fallback parsing + pesan error yang lebih ramah, serta timeout.
- **Representasi uang**
  - Pertimbangkan pakai integer rupiah (mis. `int amount`) atau decimal agar menghindari masalah pembulatan `double`.

#### P2 (fitur lanjutan sesuai scope)

- **Persistensi & sinkronisasi data**
  - Data contoh saat ini dominan in-memory / local store. Ganti repository dengan API/DB nyata bila ingin multi-device & konsistensi.
- **Manajemen katalog penjual (CRUD penuh)**
- **Pembayaran end-to-end** (status pembayaran, webhook handling lengkap, layar riwayat pembayaran)
- **Notifikasi** (in-app / push) & **chat** (sesuai scope lanjut)

### Kendala & Risiko Teknis yang Umum

- **Konfigurasi backend & port**
  - Aplikasi membaca `API_BASE_URL` via `--dart-define`. Default saat ini mengarah ke Android emulator (`10.0.2.2`) dan port tertentu.
  - Pastikan port API yang dijalankan backend cocok dengan konfigurasi aplikasi.
- **Integrasi Xendit (mode real vs demo)**
  - Endpoint create invoice butuh `XENDIT_SECRET_KEY` dan (pada implementasi backend saat ini) DB aktif; jika tidak, akan gagal.
  - Untuk demo kelas, pertimbangkan fallback “mock invoice” bila env belum siap.
- **Peta / tile OpenStreetMap**
  - Gunakan secara wajar (hindari trafik berlebihan), dan siapkan opsi tile server sendiri jika dipakai produksi.

### Konfigurasi Environment (Opsional tapi Direkomendasikan)

- **Set base URL API** (contoh saat menjalankan di Android emulator):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

- **Backend payments (Go)**
  - Jalankan backend sesuai panduan di `backend/README.md`.
  - Siapkan env `XENDIT_SECRET_KEY` bila ingin create invoice real.
