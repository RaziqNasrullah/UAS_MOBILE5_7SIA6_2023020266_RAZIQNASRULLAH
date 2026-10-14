# Analisis Kebutuhan Sistem — MyHealthGw

| Item | Keterangan |
|---|---|
| Nama aplikasi | **MyHealthGw** — *Your Personal Health Companion* |
| Nama toko | **HealthGwJirt** (Apotek Digital) |
| Package Android | `com.raziqnasrullah.myhealthgw` |
| Platform | Android (Flutter + GetX), backend REST API PHP + MySQL (XAMPP) |
| Penyusun | RAZIQNASRULLAH — 7SIA6 (NPM 2023020266) |

## 1. Deskripsi Singkat

MyHealthGw adalah aplikasi katalog & pemesanan obat bebas, vitamin, alat kesehatan, dan produk
perawatan tubuh untuk apotek **HealthGwJirt**. Pembeli dapat mencari produk, melihat golongan obat
dan aturan pakai, memasukkan produk ke keranjang, lalu checkout (ambil di tempat / diantar).
Admin apotek mengelola kategori, produk, status pesanan, dan memantau penjualan lewat dashboard.

## 2. Aktor

| Aktor | Peran |
|---|---|
| **Pengguna / Pembeli** | Menjelajah katalog, mengelola keranjang, checkout, melihat riwayat & struk. |
| **Admin Apotek** | Mengelola kategori & produk, mengubah status pesanan, melihat dashboard penjualan. |

## 3. Kebutuhan Fungsional

| Kode | Kebutuhan | Aktor |
|---|---|---|
| F-01 | Sistem menampilkan **beranda** berisi sapaan sesuai waktu, banner promo, daftar kategori (horizontal), produk unggulan, dan produk terbaru. | Pembeli |
| F-02 | Sistem menampilkan **katalog** produk dalam GridView beserta nama, kategori, harga, stok, dan golongan obat. | Pembeli |
| F-03 | Sistem menyediakan **pencarian produk berdasarkan nama secara realtime** (debounce 400 ms). | Pembeli |
| F-04 | Sistem menyediakan **filter kategori** dengan ChoiceChip termasuk opsi "Semua"; dapat dikombinasikan dengan pencarian. | Pembeli |
| F-05 | Sistem menampilkan **detail produk**: gambar, nama, kategori, harga, stok, badge golongan obat berwarna, aturan pakai, deskripsi. | Pembeli |
| F-06 | Pengguna dapat **menambah produk ke keranjang**; tombol nonaktif bila stok 0. | Pembeli |
| F-07 | Pengguna dapat **mengubah jumlah (+/−)** di keranjang dengan validasi: minimal 1 dan tidak melebihi stok. | Pembeli |
| F-08 | Pengguna dapat **menghapus item** dan mengosongkan keranjang. | Pembeli |
| F-09 | Sistem menghitung **subtotal per item dan total** secara otomatis (reaktif) dan menampilkan **badge jumlah item** di AppBar & navigasi. | Pembeli |
| F-10 | Pengguna dapat **checkout** dengan mengisi nama, nomor HP (08…, 10–13 digit), metode pengambilan, alamat (wajib jika Diantar), dan catatan. | Pembeli |
| F-11 | Sistem menghitung **subtotal, biaya layanan (Rp2.000), ongkir (Rp10.000 jika Diantar), diskon 10% (subtotal ≥ Rp150.000), dan total**. | Sistem |
| F-12 | Sistem membuat **nomor pesanan otomatis `INV-YYYYMMDD-NNN`** (NNN reset setiap hari) di server. | Sistem |
| F-13 | Sistem menyimpan pesanan ke tabel `pesanan` & `detail_pesanan`, **mengurangi stok**, dan mengosongkan keranjang dalam **satu transaksi** database. | Sistem |
| F-14 | Sistem menampilkan **riwayat pesanan** urut terbaru dengan status berwarna (Diproses, Selesai, Dibatalkan) dan filter status. | Pembeli, Admin |
| F-15 | Sistem menampilkan **detail pesanan** (item, rincian biaya, info pemesan). | Pembeli, Admin |
| F-16 | Admin dapat **mengubah status** pesanan Diproses menjadi Selesai/Dibatalkan; pembatalan **mengembalikan stok**. | Admin |
| F-17 | Sistem membuat **struk PDF** (nama toko, no pesanan, tanggal, item, rincian biaya, total), menampilkan **preview**, **menyimpan ke perangkat**, dan **membagikan**. | Pembeli, Admin |
| F-18 | Admin dapat **menambah, melihat, mengubah, menghapus kategori**; nama wajib diisi & tidak boleh duplikat (case-insensitive). | Admin |
| F-19 | Admin tidak dapat menghapus kategori yang **masih memiliki produk** (muncul pesan error jelas). | Admin |
| F-20 | Admin dapat **CRUD produk**: nama, kategori (dropdown FK), harga, stok, deskripsi, gambar (galeri), golongan obat, aturan pakai, status unggulan. | Admin |
| F-21 | Daftar produk menampilkan **nama kategori hasil query JOIN**. | Admin |
| F-22 | Admin dapat melihat **dashboard penjualan**: total pesanan, total pendapatan (status Selesai), produk terlaris, grafik BarChart top-5 dan LineChart pendapatan 7 hari. | Admin |

## 4. Kebutuhan Non-Fungsional

| Kode | Kategori | Kebutuhan |
|---|---|---|
| NF-01 | Performa | Setiap request API memiliki **timeout 15 detik**; pencarian memakai debounce 400 ms agar tidak membanjiri server; gambar produk di-cache (`cached_network_image`). |
| NF-02 | Usability | Antarmuka berbahasa Indonesia, tema warna identitas **#8ADC64** (hijau) + teal logo, ukuran sentuh ≥ 40 dp, indikator loading di setiap proses, pesan sukses/error dengan `Get.snackbar`. |
| NF-03 | Usability | Golongan obat ditandai warna sesuai penandaan resmi (hijau = bebas, biru = bebas terbatas, merah = keras). |
| NF-04 | Keandalan | Checkout & pembatalan memakai **transaksi DB** (`beginTransaction`, `SELECT … FOR UPDATE`, `commit`/`rollBack`) sehingga stok selalu konsisten. |
| NF-05 | Keandalan | Aplikasi menangani server mati, timeout, respons kosong / bukan JSON, dan stok habis tanpa crash (try-catch + tampilan error dengan tombol "Coba Lagi"). |
| NF-06 | Keamanan | Semua query memakai **PDO prepared statement** (anti SQL injection); validasi input dilakukan di aplikasi **dan** server; upload gambar dibatasi JPG/PNG/WEBP ≤ 2 MB dan eksekusi skrip di folder `uploads/` diblokir. |
| NF-07 | Integritas data | Database ternormalisasi (3NF) dengan foreign key, UNIQUE (`kategori.nama`, `pesanan.nomor_pesanan`, `keranjang.produk_id`), dan CHECK (harga > 0, jumlah ≥ 1). Harga & nama produk disalin ke `detail_pesanan` agar riwayat tidak berubah. |
| NF-08 | Kompatibilitas | Android 5.0+ (minSdk mengikuti Flutter), berjalan di emulator (`10.0.2.2`) maupun HP fisik satu jaringan Wi-Fi; HTTP lokal tetap berjalan di **APK release** (`usesCleartextTraffic`). |
| NF-09 | Maintainability | Arsitektur GetX terpisah (models, controllers, views, routes, bindings, services, widgets, theme, utils); base URL & konstanta biaya terpusat di `api_config.dart`. |
| NF-10 | Portabilitas | Base URL dapat diganti tanpa ubah kode via `--dart-define=API_BASE_URL=...`. |
