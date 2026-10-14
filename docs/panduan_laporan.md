# Bahan Laporan UAS — MyHealthGw

Susunan laporan PDF yang disarankan beserta sumber bahannya di repositori ini.

| Bab | Isi | Sumber |
|---|---|---|
| 1 | Identitas proyek & deskripsi aplikasi | `docs/kebutuhan.md` §1–2, logo `assets/logo/` |
| 2 | Analisis kebutuhan fungsional & non-fungsional | `docs/kebutuhan.md` §3–4 |
| 3 | Use Case Diagram | `docs/diagram/use_case.png` |
| 4 | Activity Diagram checkout | `docs/diagram/activity_checkout.png` |
| 5 | ERD + normalisasi | `docs/diagram/erd.png`, `docs/erd.md` |
| 6 | Struktur project (Flutter GetX & API PHP) | README §Struktur |
| 7 | Screenshot rancangan & setiap halaman | daftar di bawah |
| 8 | Black Box Testing | `docs/black_box_testing.md` (isi Hasil Aktual & Status) |
| 9 | Contoh struk PDF hasil export | `docs/contoh_struk.pdf` (contoh) + file hasil simpan dari HP |
| 10 | Kesimpulan | — |

## Daftar Halaman yang Perlu Di-screenshot (dari HP/emulator)

Folder `docs/screenshots/` sudah berisi **pratinjau rancangan** hasil render UI yang sama (build web,
data asli dari API). Untuk laporan, ambil ulang screenshot dari HP/emulator Android:

1. Splash screen (logo)
2. Beranda — sapaan, banner, kategori horizontal, produk unggulan & terbaru, badge keranjang
3. Katalog — GridView + kolom pencarian + chip kategori "Semua"
4. Katalog — hasil pencarian realtime (mis. `vit`)
5. Katalog — filter kategori aktif (mis. "Alat Kesehatan")
6. Detail produk — badge golongan obat, aturan pakai, tombol Tambah ke Keranjang
7. Detail produk stok habis (Tabir Surya SPF 50) — tombol nonaktif
8. Snackbar sukses tambah keranjang
9. Keranjang — item, tombol +/−, subtotal per item, total, badge
10. Snackbar "Melebihi stok"
11. Checkout — form + validasi error (nama kosong / no HP salah)
12. Checkout — metode Diantar (alamat muncul, ongkir & diskon di rincian)
13. Halaman pesanan berhasil (nomor INV)
14. Preview struk PDF + snackbar path tersimpan
15. Riwayat pesanan (status berwarna) + filter status
16. Detail pesanan + tombol Selesai/Batalkan
17. Dialog konfirmasi batalkan & hasil stok kembali
18. Admin — menu
19. Dashboard — kartu ringkasan
20. Dashboard — BarChart & LineChart
21. Kelola Kategori — daftar, form tambah, error duplikat, error hapus kategori berisi produk
22. Kelola Produk — daftar (nama kategori JOIN), form tambah dengan gambar & dropdown
23. Tampilan error saat server XAMPP mati (tombol Coba Lagi)
24. phpMyAdmin — struktur 5 tabel & relasi (Designer view)

## Checklist Penerimaan

- [x] Kebutuhan fungsional & non-fungsional — `docs/kebutuhan.md`
- [x] Use Case Diagram, Activity Diagram checkout, ERD — `docs/diagram/`
- [x] 5 tabel ternormalisasi dengan FK — `database/db_apotek.sql`
- [x] Folder models, controllers, views, routes, data/services, widgets (+ bindings, theme, utils)
- [x] GetMaterialApp + GetPage + Get.toNamed + arguments (Produk → Detail, id → Detail Pesanan, Pesanan → Sukses/Struk)
- [x] ThemeData terpusat + reusable widget (ProductCard, CategoryChip, CartBadgeIcon, CustomTextField, SummaryCard, EmptyState, GolonganBadge, StatusBadge, QtyStepper)
- [x] CRUD kategori + validasi kosong & duplikat (aplikasi & server)
- [x] CRUD produk + gambar + golongan obat + aturan pakai + JOIN nama kategori
- [x] Search realtime (Obx + debounce) + filter ChoiceChip
- [x] Home, Katalog (GridView), Detail + Tambah ke Keranjang
- [x] Keranjang: tambah/hapus, +/− validasi stok, total reaktif, badge
- [x] Checkout: form lengkap, INV-YYYYMMDD-NNN, biaya layanan/ongkir/diskon, stok berkurang (transaksi)
- [x] Riwayat pesanan terbaru + status + detail + ubah status (stok kembali saat batal)
- [x] Dashboard: total pesanan, pendapatan, terlaris + fl_chart
- [x] Struk PDF: preview + simpan + bagikan
- [x] try-catch + Get.snackbar di semua operasi, loading state
- [x] ≥15 skenario Black Box Testing (24 skenario)
- [ ] `flutter build apk --release` — jalankan di laptop (lihat README)
- [x] ≥4 kategori & ≥15 produk seed (4 kategori, 20 produk), README lengkap
