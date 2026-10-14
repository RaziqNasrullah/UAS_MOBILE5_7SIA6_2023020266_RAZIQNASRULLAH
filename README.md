<p align="center"><img src="assets/logo/logo_icon.png" width="120" alt="MyHealthGw"></p>

# MyHealthGw — Apotek Digital HealthGwJirt

Aplikasi mobile **Flutter + GetX** untuk katalog & pemesanan obat bebas, vitamin, alat kesehatan,
dan perawatan tubuh, dengan backend **REST API PHP (PDO)** dan database **MySQL XAMPP**.

| | |
|---|---|
| Nama aplikasi | MyHealthGw |
| Nama toko | HealthGwJirt |
| Package Android | `com.raziqnasrullah.myhealthgw` |
| Warna identitas | `#8ADC64` |
| Mahasiswa | RAZIQNASRULLAH — 7SIA6 (2023020266) |

```
Flutter (GetX)  ──HTTP/JSON──►  REST API PHP (XAMPP htdocs/apotek_api)  ──PDO──►  MySQL db_apotek
```

---

## 1. Struktur Repositori

```
.
├── lib/                      # Source code Flutter
│   ├── main.dart             # GetMaterialApp + ThemeData + initialBinding
│   └── app/
│       ├── models/           # kategori, produk, keranjang_item, pesanan, detail_pesanan, dashboard_summary
│       ├── controllers/      # main, home, katalog, produk_detail, kategori, produk, cart, checkout, pesanan, dashboard, struk
│       ├── views/            # satu folder per halaman
│       ├── routes/           # app_routes.dart (nama route) + app_pages.dart (GetPage)
│       ├── bindings/         # binding per halaman
│       ├── data/services/    # api_config, api_service (http), *_service
│       ├── widgets/          # ProductCard, CategoryChip, CartBadgeIcon, CustomTextField, SummaryCard, EmptyState, ...
│       ├── theme/            # app_theme.dart, app_colors.dart
│       └── utils/            # formatter, validators, biaya_calculator, pdf_generator, app_snackbar
├── backend/apotek_api/       # REST API PHP → salin ke C:\xampp\htdocs\apotek_api
├── database/db_apotek.sql    # skema 5 tabel + data seed (4 kategori, 20 produk, 4 pesanan contoh)
├── docs/                     # kebutuhan, diagram (PlantUML + PNG), ERD, black box testing, bahan laporan
├── assets/logo/              # logo & ikon launcher
├── scripts/                  # script zip source code
└── test/                     # unit test (flutter test)
```

## 2. Setup XAMPP & Database

1. Install **XAMPP** (PHP ≥ 8.0), buka *XAMPP Control Panel*, **Start Apache** dan **Start MySQL**.
2. Buka `http://localhost/phpmyadmin` → tab **Import** → pilih `database/db_apotek.sql` → **Go**.
   Script membuat database `db_apotek` (InnoDB, utf8mb4) lengkap dengan data seed.
3. Salin folder **`backend/apotek_api`** ke **`C:\xampp\htdocs\apotek_api`**
   (Linux: `/opt/lampp/htdocs/apotek_api`, macOS: `/Applications/XAMPP/htdocs/apotek_api`).
4. Jika MySQL memakai password, ubah `DB_USER` / `DB_PASS` di `apotek_api/config/database.php`.
5. Tes di browser: `http://localhost/apotek_api/` → harus muncul
   `{"success":true,"message":"API Apotek HealthGwJirt aktif & database terhubung.", ...}`.

### Endpoint API

Semua respons berformat `{ "success": bool, "message": string, "data": ... }` dengan HTTP status yang sesuai
(200/201 sukses, 404 tidak ditemukan, 405 method salah, 409 konflik/duplikat/stok, 422 validasi, 500 server).

| Method | Endpoint | Body / Query |
|---|---|---|
| GET | `kategori/read.php` | `?id=` (opsional) |
| POST | `kategori/create.php` | `{nama, deskripsi}` |
| POST | `kategori/update.php` | `{id, nama, deskripsi}` |
| POST | `kategori/delete.php` | `{id}` — ditolak (409) jika masih punya produk |
| GET | `produk/read.php` | `?search=&kategori_id=&unggulan=1&limit=&sort=terbaru` (JOIN nama kategori) |
| GET | `produk/detail.php` | `?id=` |
| POST | `produk/create.php` / `update.php` | `{id?, kategori_id, nama, harga, stok, deskripsi, gambar, golongan_obat, aturan_pakai, is_unggulan}` |
| POST | `produk/delete.php` | `{id}` |
| POST | `produk/upload_gambar.php` | multipart field `gambar` (JPG/PNG/WEBP ≤ 2 MB) → `{gambar: "<file>"}` |
| GET | `keranjang/read.php` | — |
| POST | `keranjang/add.php` | `{produk_id, jumlah}` |
| POST | `keranjang/update_qty.php` | `{id, jumlah}` |
| POST | `keranjang/delete.php` / `clear.php` | `{id}` / — |
| POST | `pesanan/checkout.php` | `{nama_pemesan, no_hp, metode_pengambilan, alamat, catatan}` (transaksi DB) |
| GET | `pesanan/read.php` | `?status=` (urut terbaru) |
| GET | `pesanan/detail.php` | `?id=` |
| POST | `pesanan/update_status.php` | `{id, status: "Selesai"/"Dibatalkan"}` (batal → stok kembali) |
| GET | `dashboard/summary.php` | — |

Contoh uji dengan `curl` (atau Postman):

```bash
B=http://localhost/apotek_api
curl "$B/produk/read.php?search=vit&kategori_id=2"
curl -X POST -H "Content-Type: application/json" -d '{"nama":"obat bebas"}' $B/kategori/create.php   # 409 duplikat
curl -X POST -H "Content-Type: application/json" -d '{"produk_id":6,"jumlah":2}' $B/keranjang/add.php
curl -X POST -H "Content-Type: application/json" \
     -d '{"nama_pemesan":"Raziq","no_hp":"081234567890","metode_pengambilan":"Diantar","alamat":"Jl. Kampus 1"}' \
     $B/pesanan/checkout.php                                                                         # INV-YYYYMMDD-NNN
curl -X POST -H "Content-Type: application/json" -d '{"id":1,"status":"Dibatalkan"}' $B/pesanan/update_status.php
curl -F "gambar=@foto.jpg" $B/produk/upload_gambar.php
curl $B/dashboard/summary.php
```

## 3. Mengatur Base URL API

File: **`lib/app/data/services/api_config.dart`**

| Perangkat | Base URL |
|---|---|
| Emulator Android (default) | `http://10.0.2.2/apotek_api` |
| HP fisik (satu Wi-Fi dengan laptop) | `http://<IP-LAN-laptop>/apotek_api` — cek IP dengan `ipconfig` (Windows) |

Tanpa mengubah kode, bisa juga memakai `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/apotek_api
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10/apotek_api
```

Untuk HP fisik: pastikan **Windows Firewall** mengizinkan Apache (port 80) pada jaringan privat.
Base URL yang sedang dipakai bisa dilihat di tab **Admin** aplikasi.

## 4. Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

Kebutuhan: Flutter **3.35 atau lebih baru** (Dart ≥ 3.9; diuji dengan Flutter 3.41.6 / Dart 3.11.4), Android SDK.
Jika muncul error *version solving failed*, jalankan `flutter pub upgrade` lalu `flutter pub get`.

Pengujian:

```bash
flutter analyze      # No issues found
flutter test         # unit test validator, kalkulasi biaya, model, struk PDF
```

## 5. Build APK Release

```bash
flutter clean
flutter pub get
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

Instal ke HP: salin `app-release.apk` ke HP lalu buka (izinkan *Install unknown apps*), atau
`adb install build/app/outputs/flutter-apk/app-release.apk`.

HTTP lokal tetap berfungsi di APK release karena `AndroidManifest.xml` (main) sudah berisi
permission `INTERNET`, `android:usesCleartextTraffic="true"`, dan `network_security_config.xml`.
Nama aplikasi **MyHealthGw** dan ikon launcher dari logo sudah dipasang
(regenerasi ikon: `dart run flutter_launcher_icons`).

## 6. Zip Source Code (tanpa build/)

```bash
# Linux / macOS / Git Bash
bash scripts/zip_source.sh
```
```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File scripts\zip_source.ps1
```

Menghasilkan `MyHealthGw_source_2023020266.zip` yang mengecualikan `build/`, `.dart_tool/`, `.idea/`,
`.gradle/`, dan file lokal lain.

## 7. Fitur

- Beranda (sapaan, banner, kategori horizontal, unggulan, terbaru), Katalog GridView, Detail produk
- Pencarian realtime (`.obs` + `Obx` + `debounce` 400 ms) + filter `ChoiceChip` kategori (kombinasi)
- CRUD kategori (validasi kosong & duplikat, tolak hapus jika masih punya produk)
- CRUD produk (dropdown kategori FK, gambar dari galeri, golongan obat, aturan pakai, unggulan, JOIN nama kategori)
- Keranjang (`CartController` permanen, tersimpan di tabel `keranjang`, validasi stok, total reaktif, badge)
- Checkout (validasi form, biaya layanan/ongkir/diskon, `INV-YYYYMMDD-NNN`, transaksi DB, stok berkurang)
- Riwayat pesanan (urut terbaru, filter & warna status), detail, ubah status (batal → stok kembali)
- Dashboard (kartu ringkasan, BarChart top-5, LineChart pendapatan 7 hari — `fl_chart`)
- Struk PDF (`pdf` + `printing`): preview, simpan ke perangkat, bagikan
- Error handling: try-catch di semua request (timeout, server mati, respons kosong/bukan JSON), `Get.snackbar`, loading state

Dokumen analisis & pengujian ada di folder [`docs/`](docs/).
