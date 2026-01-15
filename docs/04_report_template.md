# Laporan Proyek Pasar Lokal MVVM

## 1. Ringkasan & Tujuan

**Nama aplikasi:** Pasar Lokal MVVM

**Masalah yang disasar:** Memudahkan pembeli menemukan produk lokal dan penjual mengelola katalog serta pesanan.

**Fitur inti (3–5):**

1. Autentikasi demo (pembeli/penjual) dan profil akun.
2. Katalog produk + detail produk.
3. Keranjang belanja dan checkout (invoice).
4. Pesanan dan status pembayaran.
5. Profil & pengaturan (ubah profil, metode pembayaran, bantuan).

## 2. Desain & Arsitektur

**Pola:** MVVM (Model–View–ViewModel)

**Pemisahan tanggung jawab:**

- **Model**: `lib/core/models/*`
- **Repository**: `lib/core/repositories/*` (sumber data in-memory / API)
- **ViewModel**: `lib/features/**/viewmodels/*` (state & aturan bisnis)
- **View**: `lib/features/**/views/*` (UI)

**Alur navigasi utama:**

- Beranda → Detail produk → Keranjang → Checkout
- Tab Peta → lokasi penjual
- Tab Pesanan → status pembayaran
- Tab Akun → profil & pengaturan

## 3. Implementasi Fitur

Ringkas poin implementasi utama:

- **Autentikasi demo**: `AuthViewModel` + `AuthRepository`
- **Katalog & produk**: `ProductViewModel` + `ProductRepository`
- **Checkout & pembayaran**: `PaymentViewModel` + `PaymentRepository`
- **Metode pembayaran**: `PaymentMethodsViewModel` + `PaymentMethodRepository`
- **Profil & pengaturan**: `EditProfilePage`, `HelpPage`

## 4. Usability Testing

**Metode:** Moderated task-based testing (1 peserta, keterbatasan waktu)

**Skenario tugas:**

1. Login sebagai pembeli.
2. Cari produk, lihat detail, tambah ke keranjang.
3. Checkout dan lihat status pembayaran.
4. Login sebagai penjual dan tambah produk.
5. Cek katalog penjual dan ubah profil.

**Keterbatasan:** Hanya 1 peserta yang berhasil diuji sebelum deadline. Catatan ini dicantumkan agar evaluasi tetap transparan.

**Temuan utama & perbaikan:**

- Temuan #1: Pengguna butuh akses cepat ke katalog toko.
  - Perbaikan: Tambah navigasi katalog dari halaman akun penjual.
- Temuan #2: Alur tambah produk sempat memunculkan error saat simpan.
  - Perbaikan: Refactor bottom sheet tambah produk agar aman dari controller dispose.
- Temuan #3: Informasi metode pembayaran kurang jelas.
  - Perbaikan: Tambahkan label “Metode utama” dan pengelolaan metode.
- Temuan #4: Login Google sempat error dan peta belum real-time.
  - Perbaikan: Dicatat sebagai keterbatasan (perlu konfigurasi & refresh data).

## 5. Tantangan & Solusi

- Tantangan: Integrasi data demo dengan navigasi multi-tab.
- Solusi: Gunakan MVVM + HomeTabScope untuk kontrol tab secara terpusat.

## 6. Screenshot

Sertakan minimal 4–8 screenshot (lihat `docs/screenshots/README.md`).

- Login
![alt text](image.png)
- Beranda / daftar produk
![alt text](image-1.png)
- Detail produk
![alt text](image-2.png)
- Keranjang / checkout
![alt text](image-3.png)
![alt text](image-4.png)
- Pesanan
![alt text](image-5.png)
- Peta
![alt text](image-6.png)
- Profil / akun
![alt text](image-7.png)


## 7. Link Repository

- Repo: https://github.com/1oneGod1/pasar-lokal-mvvm

## 8. Cara Menjalankan

```bash
flutter pub get
flutter run -d emulator-5554
```

## 9. Kesimpulan

Aplikasi memenuhi kebutuhan dasar pembeli dan penjual dengan alur yang jelas dan UI sederhana. Rencana berikutnya: integrasi backend nyata untuk pembayaran dan sinkronisasi pesanan real-time.
