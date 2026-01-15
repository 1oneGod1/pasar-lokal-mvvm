# Usability Test Results (1 Participant)

> Isi bagian yang masih placeholder sesuai hasil real Anda.

## Rubric Checklist (pastikan terisi)

- [ ] Peserta minimal 3 orang (P1–P3)
- [x] Ada 5–6 task inti (login, cari/buka produk, add cart, lihat cart, checkout, navigasi)
- [x] Ada data success/help/time + catatan
- [x] Ada temuan utama + rencana perbaikan
- [x] Ada minimal 1–2 perubahan yang benar-benar diterapkan setelah testing

## Summary Findings (ringkas)

- Desain UI masih kurang oke menurut peserta (butuh perapihan visual).
- Login Google sempat error.
- Pesanan yang sudah checkout tidak bisa diedit.
- Peta belum real-time.

## Participant Info

- P1: Pembeli (1 peserta). Pengalaman belanja online: sedang. Familiar dengan aplikasi e-commerce umum.

## Task Results Table

Keterangan:

- Success: Yes/No
- Help: Yes/No (apakah butuh arahan)
- SEQ (Single Ease Question): 1–7 (1 sangat sulit, 7 sangat mudah)

| Task                                | P1 Success | P1 Help | P1 Time | P1 Notes                                   |
| ----------------------------------- | ---------- | ------: | ------: | ------------------------------------------ |
| Login pembeli                       | Yes        |      No |     ~1m | Login demo berjalan baik                   |
| Cari produk / buka detail           | Yes        |      No |     ~1m | Tidak ada kendala                          |
| Tambah ke keranjang                 | Yes        |      No |     ~1m | Tombol add jelas                           |
| Lihat keranjang & total             | Yes        |      No |     ~1m | Total mudah dipahami                       |
| Checkout / buat pesanan             | Yes        |      No |   ~1–2m | Pesanan terbentuk, namun tidak bisa diedit |
| Navigasi tab (Peta/Pesanan/Beranda) | Yes        |      No |    ~30s | Peta dinilai belum real-time               |

## Post-Test Ratings (Likert 1–5)

| Statement                |  P1 |
| ------------------------ | --: |
| Navigasi mudah dipahami  |   4 |
| Mudah menemukan produk   |   4 |
| Keranjang/checkout jelas |   4 |
| Tampilan nyaman dibaca   |   3 |

## Issues & Proposed Fixes

1. **Desain UI masih kurang oke**
   - Evidence: Komentar langsung dari P1
   - Fix: Rapikan spacing/typography, konsistensi warna, tambah kontras
2. **Login Google error**
   - Evidence: P1 gagal login dengan Google
   - Fix: Pastikan `GOOGLE_WEB_CLIENT_ID` di-set (web) atau gunakan login demo
3. **Pesanan yang sudah checkout tidak bisa diedit**
   - Evidence: P1 mencoba edit pesanan
   - Fix: Tambahkan fitur edit pesanan atau jelaskan bahwa pesanan terkunci setelah checkout
4. **Peta belum real-time**
   - Evidence: P1 berharap lokasi berubah dinamis
   - Fix: Tambahkan refresh manual / auto refresh data lokasi

## Changes Applied After Testing

- Perubahan 1:
  - Temuan: Akses katalog toko kurang cepat
  - Perubahan yang dilakukan: Tambah navigasi katalog dari halaman Akun penjual
  - Bukti: [nama screenshot / catatan commit]
- Perubahan 2:
  - Temuan: Error saat simpan produk di dashboard penjual
  - Perubahan yang dilakukan: Refactor bottom sheet tambah produk
  - Bukti: [nama screenshot / catatan commit]

## Catatan Keterbatasan

Testing baru dilakukan dengan 1 peserta. Rencana: tambah minimal 2 peserta lagi untuk memenuhi target tugas.
