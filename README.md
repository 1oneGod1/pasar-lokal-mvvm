# Pasar Lokal MVVM

Pasar Lokal MVVM adalah prototipe marketplace lingkungan berbasis Flutter 3.7 yang menerapkan pola **Model–View–ViewModel (MVVM)** dari hulu ke hilir. Proyek ini memperlihatkan bagaimana memisahkan tampilan, logika domain, dan akses data sambil menyajikan pengalaman pembeli dan penjual dalam satu codebase.

## Sorotan Fitur

- **Antarmuka abu-abu** sesuai mockup AFL1 dengan navigasi bawah (`Beranda`, `Peta`, `Pesanan`, `Akun`).
- **Alur pembeli** mencakup eksplorasi produk, pengelolaan keranjang, checkout, dan pelacakan pesanan.
- **Dashboard penjual** menampilkan KPI toko, ringkasan stok, serta pipeline pesanan saat login sebagai penjual.
- **Tab peta** menggunakan [`flutter_map`](https://pub.dev/packages/flutter_map) + OpenStreetMap untuk memvisualisasikan penjual terdekat.
- **Lapisan MVVM yang dapat digunakan ulang** (model, repository, viewmodel) dengan `provider` untuk injeksi dependensi dan pembaruan state.

## Ringkasan Arsitektur

| Lapisan        | Deskripsi |
| -------------- | --------- |
| **Models**     | Objek Dart sederhana di `lib/core/models` mendeskripsikan entitas seperti `Product`, `Order`, `MapLocation`, dan `User` (dengan peran pembeli/penjual). |
| **Repositories** | Penyimpanan in-memory di `lib/core/repositories` memuat data contoh dan logika CRUD. Dapat diganti dengan API atau basis data nyata. |
| **ViewModels** | Kelas `ChangeNotifier` di `lib/features/**/viewmodels` menerjemahkan data repository menjadi state siap pakai, mengekspose aturan bisnis, serta mengoordinasikan alur fitur. |
| **Views**      | Layar dan widget Material 3 di `lib/features/**/views` berlangganan provider dan merender UI reaktif. |

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

## Akun Demo Pembeli & Penjual

Kredensial demo tersimpan di `AuthRepository`.

| Peran    | Email                        | Kata sandi   | Catatan |
| -------- | ---------------------------- | ------------ | ------- |
| Pembeli  | `andi@example.com`           | `rahasia123` | Sudah terisi di form login. |
| Pembeli  | `sari@example.com`           | `belanja123` | Pakai tombol demo untuk mengisi otomatis. |
| Penjual  | `putri.seller@pasarlokal.id` | `spicehouse` | Mengakses dashboard penjual milik Putri Spice House. |

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

## Pengujian

Widget test mencakup alur autentikasi pembeli dan penjual. Jalankan dengan perintah:

```bash
flutter test
```

> ℹ️ Tab peta memakai ubin OpenStreetMap. Saat test, mungkin muncul peringatan terkait subdomain ubin; tidak berpengaruh pada fungsi, namun Anda bisa mengganti ke pola host tunggal (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`) bila ingin.

## Catatan & Pengembangan Lanjutan

- Data contoh masih tersimpan di memori. Ganti repository dengan sumber data jarak jauh bila ingin persistensi.
- Marker peta berasal dari `MapRepository`; hubungkan dengan backend atau layanan geolokasi untuk data real-time.
- Aksi penjual (`Kelola toko`, `Lihat katalog`) masih menjadi placeholder untuk fitur berikutnya.

## Unggah ke GitHub (Langkah Manual)

Workspace ini tidak otomatis mendorong ke GitHub. Lakukan manual di mesin lokal:

1. [Buat repositori kosong di GitHub](https://github.com/new) (jangan centang opsi README karena proyek ini sudah memilikinya).
2. Inisialisasi git dan pasang remote di root proyek:
	```bash
	git init
	git add .
	git commit -m "Initial commit: Pasar Lokal MVVM"
	git remote add origin https://github.com/<username>/<repo>.git
	```
3. Dorong branch utama:
	```bash
	git push -u origin main
	```

Ganti `<username>` dan `<repo>` dengan akun GitHub Anda. Setelah push berhasil, README ini akan tampil sebagai halaman utama repositori.
