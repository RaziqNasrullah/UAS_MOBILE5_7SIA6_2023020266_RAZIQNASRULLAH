# Black Box Testing — MyHealthGw

Pengujian dilakukan dengan metode **black box** (equivalence partitioning & boundary value) pada
aplikasi Android yang terhubung ke API XAMPP. Kolom **Hasil Aktual** dan **Status** diisi setelah
pengujian manual di perangkat. Baris **No. 1** berisi contoh cara pengisian.

> Status: ✅ Berhasil / ❌ Gagal. Tuliskan juga perangkat uji (mis. *Emulator Pixel 7 API 34* / *HP Redmi Note 12*).

| No | Fitur | Skenario | Hasil yang Diharapkan | Hasil Aktual | Status |
|---|---|---|---|---|---|
| 1 | Kategori – validasi kosong | Admin > Kelola Kategori > tambah, kosongkan nama, tekan **Simpan** | Muncul pesan "Nama kategori wajib diisi", data tidak tersimpan | *Contoh: Pesan "Nama kategori wajib diisi" tampil di bawah field dan snackbar "Form belum valid"; tidak ada data baru* | *✅ Berhasil* |
| 2 | Kategori – validasi duplikat | Tambah kategori dengan nama `obat bebas` (sudah ada "Obat Bebas") | Ditolak dengan pesan "Nama kategori sudah digunakan" (cek di aplikasi & server, case-insensitive) | | |
| 3 | Kategori – create/update | Tambah kategori "Ibu & Anak", lalu ubah namanya menjadi "Ibu dan Anak" | Snackbar sukses, daftar & chip filter katalog ikut diperbarui | | |
| 4 | Kategori – hapus kategori berisi produk | Hapus kategori "Obat Bebas" | Ditolak: "Kategori … tidak dapat dihapus karena masih memiliki 5 produk" | | |
| 5 | Produk – create dengan gambar | Admin > Kelola Produk > tambah: isi semua field, pilih kategori, golongan obat, aturan pakai, pilih gambar dari galeri, Simpan | Produk tersimpan, gambar terunggah ke `uploads/`, tampil di katalog dengan nama kategori (JOIN) | | |
| 6 | Produk – validasi | Isi harga `0` dan kosongkan aturan pakai, Simpan | Muncul pesan "Harga harus lebih dari 0" & "Aturan pakai wajib diisi"; tidak tersimpan | | |
| 7 | Produk – update & delete | Ubah stok produk lalu hapus produk lain | Perubahan stok tampil di katalog; produk terhapus hilang dari daftar, riwayat pesanan lama tetap utuh | | |
| 8 | Pencarian realtime | Katalog > ketik `vit` | Daftar langsung tersaring (±0,4 detik setelah berhenti mengetik) tanpa menekan tombol | | |
| 9 | Filter kategori + kombinasi | Pilih chip "Vitamin & Suplemen", lalu ketik `omega` | Hanya produk kategori tersebut yang mengandung "omega"; chip "Semua" menampilkan seluruh produk | | |
| 10 | Detail & tambah keranjang | Buka detail "Vitamin C 500 mg", tekan **Tambah ke Keranjang** | Snackbar "ditambahkan ke keranjang", badge keranjang di AppBar & navigasi bertambah | | |
| 11 | Produk stok habis | Buka detail "Tabir Surya SPF 50" (stok 0) | Tombol berubah "Stok Habis" dan nonaktif | | |
| 12 | Keranjang – qty melebihi stok | Di keranjang, tekan **+** pada "Tensimeter" hingga melebihi stok (12) | Muncul pesan "Stok … hanya 12", jumlah tidak bertambah | | |
| 13 | Keranjang – total reaktif & hapus | Ubah qty +/−, lalu hapus satu item | Subtotal item & total berubah otomatis; item terhapus; qty tidak bisa < 1 (muncul konfirmasi hapus) | | |
| 14 | Checkout – form kosong | Checkout tanpa mengisi nama & HP | Pesan validasi "Nama pemesan wajib diisi" & "Nomor HP wajib diisi" | | |
| 15 | Checkout – no HP salah | Isi HP `0712345` | Pesan "Nomor HP harus diawali 08" / "harus 10-13 digit" | | |
| 16 | Checkout – alamat wajib jika Diantar | Pilih metode **Diantar**, kosongkan alamat | Field alamat muncul dan wajib diisi; ongkir Rp10.000 masuk rincian | | |
| 17 | Checkout sukses + stok berkurang | Checkout 2 × Vitamin C (stok awal 75), Ambil di Tempat | Halaman sukses tampil, keranjang kosong, stok Vitamin C menjadi 73 | | |
| 18 | Perhitungan biaya & diskon | Checkout subtotal ≥ Rp150.000 metode Diantar | Biaya layanan Rp2.000, ongkir Rp10.000, diskon 10% subtotal, total = subtotal + 2.000 + 10.000 − diskon | | |
| 19 | Nomor INV otomatis | Buat 2 pesanan di hari yang sama | Nomor berurutan `INV-YYYYMMDD-001`, `INV-YYYYMMDD-002` (reset di hari berikutnya) | | |
| 20 | Riwayat urut terbaru | Buka tab **Riwayat** | Pesanan terbaru di paling atas; status berwarna (kuning Diproses, hijau Selesai, merah Dibatalkan); filter status berfungsi | | |
| 21 | Ubah status & kembalikan stok | Buka detail pesanan Diproses > **Batalkan** | Status menjadi Dibatalkan, stok produk kembali; pesanan tidak bisa diubah lagi | | |
| 22 | Dashboard | Admin > Dashboard Penjualan | Total pesanan, total pendapatan (hanya Selesai), produk terlaris, BarChart top-5 & LineChart 7 hari tampil | | |
| 23 | Export struk PDF | Detail pesanan > **Cetak Struk PDF** > **Simpan PDF** | Preview PDF berisi nama toko, no pesanan, tanggal, item, rincian, total; snackbar menampilkan path file tersimpan | | |
| 24 | Error handling server mati | Matikan Apache/MySQL XAMPP lalu tarik untuk refresh katalog | Muncul pesan "Tidak dapat terhubung ke server…" / timeout dengan tombol **Coba Lagi**, aplikasi tidak crash | | |

## Ringkasan Hasil

| Total skenario | Berhasil | Gagal |
|---|---|---|
| 24 | … | … |

## Pengujian Otomatis Pendukung

Selain uji manual di atas, tersedia unit test (`flutter test`) untuk validator form, kalkulasi biaya
(diskon/ongkir), parsing model JSON, dan pembuatan struk PDF — **20 test lulus**.
Endpoint API juga diuji dengan `curl` (contoh request ada di README).
