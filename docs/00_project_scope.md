# Project Scope (AFL)

## Problem / Need

Banyak pembeli ingin menemukan produk lokal terdekat dengan cepat, sementara penjual lokal ingin mempromosikan produk dan memantau pesanan secara sederhana.

Aplikasi **Pasar Lokal MVVM** adalah prototipe marketplace yang memfasilitasi:

- pembeli: eksplorasi produk, keranjang, checkout, dan tracking pesanan
- penjual: dashboard ringkas (KPI/pipeline) setelah login sebagai penjual

## Core Functionality (fitur inti yang wajib stabil)

1. **Auth demo**: login pembeli/penjual + register + Google sign-in (demo)
2. **Browse produk**: lihat daftar produk + detail produk
3. **Keranjang**: tambah item, ubah quantity, hapus, hitung total
4. **Checkout & pesanan**: buat pesanan dari keranjang, lihat riwayat pesanan
5. **Navigasi**: bottom navigation (`Beranda`, `Peta`, `Pesanan`, `Akun`)

## Out of Scope (ditunda supaya scope aman)

- pembayaran real end-to-end (hanya demo/integrasi dasar)
- notifikasi push
- manajemen katalog penjual lengkap (CRUD penuh)
- fitur chat

## Definition of Done

- Semua fitur inti di atas bisa dijalankan tanpa crash
- Navigasi jelas dan konsisten
- Usability test minimal 3 user selesai + perbaikan utama sudah diterapkan
- Laporan 2–3 halaman + screenshot + link repo tersedia
