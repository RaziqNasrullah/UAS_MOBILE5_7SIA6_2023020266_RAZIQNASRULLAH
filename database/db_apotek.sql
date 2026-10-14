-- =====================================================================
--  MyHealthGw — Apotek Digital "HealthGwJirt"
--  Skema database + data seed (MySQL / MariaDB XAMPP)
--  Penyusun : RAZIQNASRULLAH — 7SIA6
--  Cara pakai: phpMyAdmin > Import > pilih file ini > Go
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+07:00';
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS db_apotek;
CREATE DATABASE db_apotek CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_apotek;

-- ---------------------------------------------------------------------
-- 1. kategori
-- ---------------------------------------------------------------------
CREATE TABLE kategori (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nama        VARCHAR(100) NOT NULL,
    deskripsi   VARCHAR(255) NULL,
    ikon        VARCHAR(50)  NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_kategori_nama (nama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. produk (N produk -> 1 kategori)
-- ---------------------------------------------------------------------
CREATE TABLE produk (
    id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    kategori_id    INT UNSIGNED NOT NULL,
    nama           VARCHAR(150) NOT NULL,
    harga          DECIMAL(12,2) NOT NULL,
    stok           INT UNSIGNED NOT NULL DEFAULT 0,
    deskripsi      TEXT NOT NULL,
    gambar         VARCHAR(255) NULL,
    golongan_obat  ENUM('Obat Bebas','Obat Bebas Terbatas','Obat Keras','Jamu/Herbal','Non-Obat') NOT NULL DEFAULT 'Non-Obat',
    aturan_pakai   TEXT NOT NULL,
    is_unggulan    TINYINT(1) NOT NULL DEFAULT 0,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_produk_kategori (kategori_id),
    KEY idx_produk_nama (nama),
    CONSTRAINT fk_produk_kategori FOREIGN KEY (kategori_id)
        REFERENCES kategori (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_produk_harga CHECK (harga > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. keranjang (1 baris per produk)
-- ---------------------------------------------------------------------
CREATE TABLE keranjang (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    produk_id   INT UNSIGNED NOT NULL,
    jumlah      INT UNSIGNED NOT NULL DEFAULT 1,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_keranjang_produk (produk_id),
    CONSTRAINT fk_keranjang_produk FOREIGN KEY (produk_id)
        REFERENCES produk (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_keranjang_jumlah CHECK (jumlah >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. pesanan (header transaksi)
-- ---------------------------------------------------------------------
CREATE TABLE pesanan (
    id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nomor_pesanan       VARCHAR(20) NOT NULL,
    nama_pemesan        VARCHAR(100) NOT NULL,
    no_hp               VARCHAR(15) NOT NULL,
    metode_pengambilan  ENUM('Ambil di Tempat','Diantar') NOT NULL DEFAULT 'Ambil di Tempat',
    alamat              TEXT NULL,
    catatan             TEXT NULL,
    subtotal            DECIMAL(12,2) NOT NULL DEFAULT 0,
    biaya_layanan       DECIMAL(12,2) NOT NULL DEFAULT 0,
    ongkir              DECIMAL(12,2) NOT NULL DEFAULT 0,
    diskon              DECIMAL(12,2) NOT NULL DEFAULT 0,
    total               DECIMAL(12,2) NOT NULL DEFAULT 0,
    status              ENUM('Diproses','Selesai','Dibatalkan') NOT NULL DEFAULT 'Diproses',
    tanggal             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_pesanan_nomor (nomor_pesanan),
    KEY idx_pesanan_tanggal (tanggal),
    KEY idx_pesanan_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. detail_pesanan (item transaksi, menyimpan snapshot nama & harga)
-- ---------------------------------------------------------------------
CREATE TABLE detail_pesanan (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    pesanan_id    INT UNSIGNED NOT NULL,
    produk_id     INT UNSIGNED NULL,
    nama_produk   VARCHAR(150) NOT NULL,
    harga_satuan  DECIMAL(12,2) NOT NULL,
    jumlah        INT UNSIGNED NOT NULL,
    subtotal      DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id),
    KEY idx_detail_pesanan (pesanan_id),
    KEY idx_detail_produk (produk_id),
    CONSTRAINT fk_detail_pesanan FOREIGN KEY (pesanan_id)
        REFERENCES pesanan (id) ON UPDATE CASCADE ON DELETE CASCADE,
    -- produk boleh dihapus admin; riwayat tetap aman karena nama & harga disalin (snapshot)
    CONSTRAINT fk_detail_produk FOREIGN KEY (produk_id)
        REFERENCES produk (id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  DATA SEED
-- =====================================================================

INSERT INTO kategori (id, nama, deskripsi, ikon) VALUES
(1, 'Obat Bebas',         'Obat untuk keluhan ringan yang dapat dibeli tanpa resep dokter.',      'medication'),
(2, 'Vitamin & Suplemen', 'Vitamin, mineral, dan suplemen untuk menjaga daya tahan tubuh.',        'vitamin'),
(3, 'Alat Kesehatan',     'Peralatan pemeriksaan dan pertolongan pertama untuk di rumah.',         'medical'),
(4, 'Perawatan Tubuh',    'Produk kebersihan dan perawatan kulit sehari-hari.',                    'spa');

INSERT INTO produk (id, kategori_id, nama, harga, stok, deskripsi, gambar, golongan_obat, aturan_pakai, is_unggulan) VALUES
-- ---------- Obat Bebas ----------
(1, 1, 'Parasetamol 500 mg Tablet (Strip 10)', 8500, 120,
 'Pereda demam dan nyeri ringan seperti sakit kepala, sakit gigi, dan nyeri otot. Kemasan strip isi 10 tablet.',
 'p01_parasetamol.png', 'Obat Bebas',
 'Dewasa: 1-2 tablet, 3-4 kali sehari (maksimal 8 tablet/hari). Anak 6-12 tahun: 1/2-1 tablet, 3-4 kali sehari. Diminum sesudah makan. Jangan digunakan lebih dari 3 hari untuk demam tanpa konsultasi dokter.', 1),
(2, 1, 'Antasida DOEN Tablet Kunyah (Strip 10)', 6000, 80,
 'Mengurangi gejala kelebihan asam lambung, perih ulu hati, dan kembung. Mengandung aluminium hidroksida dan magnesium hidroksida.',
 'p02_antasida.png', 'Obat Bebas',
 'Dewasa: 1-2 tablet dikunyah, 3-4 kali sehari. Anak 6-12 tahun: 1/2-1 tablet, 3-4 kali sehari. Diminum 1 jam sebelum makan dan menjelang tidur.', 0),
(3, 1, 'Sirup Obat Batuk Hitam (OBH) 100 ml', 14500, 60,
 'Membantu meredakan batuk berdahak dan melegakan tenggorokan. Kemasan botol 100 ml dengan sendok takar.',
 'p03_obh.png', 'Obat Bebas Terbatas',
 'Dewasa: 3 kali sehari 15 ml (1 sendok makan). Anak 6-12 tahun: 3 kali sehari 5 ml (1 sendok teh). Kocok dahulu sebelum diminum. P. No. 1: Awas! Obat keras, bacalah aturan pemakaiannya.', 1),
(4, 1, 'Klorfeniramin Maleat (CTM) 4 mg Tablet', 4000, 90,
 'Antihistamin untuk meredakan gejala alergi seperti bersin, gatal, dan biduran.',
 'p04_ctm.png', 'Obat Bebas Terbatas',
 'Dewasa: 1 tablet, 3-4 kali sehari. Anak 6-12 tahun: 1/2 tablet, 3-4 kali sehari. Dapat menyebabkan kantuk, jangan mengemudi setelah minum obat ini.', 0),
(5, 1, 'Oralit Serbuk 200 ml (Sachet)', 2500, 150,
 'Garam rehidrasi oral untuk mencegah dan mengatasi kekurangan cairan tubuh akibat diare atau muntah.',
 'p05_oralit.png', 'Obat Bebas',
 'Larutkan 1 sachet dalam 200 ml (1 gelas) air matang. Dewasa: 1-2 gelas setiap habis buang air besar. Anak: 1/2-1 gelas setiap habis buang air besar. Larutan dibuang setelah 24 jam.', 0),

-- ---------- Vitamin & Suplemen ----------
(6, 2, 'Vitamin C 500 mg Tablet Hisap (Botol 30)', 25000, 75,
 'Membantu memelihara daya tahan tubuh dan sebagai antioksidan. Rasa jeruk, isi 30 tablet hisap.',
 'p06_vitc.png', 'Obat Bebas',
 '1 tablet sehari, dihisap atau dikunyah sesudah makan. Tidak dianjurkan melebihi dosis yang disarankan.', 1),
(7, 2, 'Vitamin D3 1000 IU Softgel (Botol 30)', 65000, 40,
 'Membantu penyerapan kalsium untuk kesehatan tulang, gigi, dan mendukung sistem imun.',
 'p07_vitd3.png', 'Obat Bebas',
 'Dewasa: 1 softgel sehari sesudah makan. Simpan di tempat sejuk dan kering, terhindar dari sinar matahari.', 1),
(8, 2, 'Multivitamin Anak Sirup 60 ml', 32000, 50,
 'Kombinasi vitamin A, B kompleks, C, dan D untuk membantu memenuhi kebutuhan vitamin anak dan menambah nafsu makan.',
 'p08_multivit.png', 'Obat Bebas',
 'Anak 1-6 tahun: 1 sendok takar (5 ml) sehari. Anak 6-12 tahun: 2 sendok takar (10 ml) sehari. Kocok dahulu sebelum digunakan.', 0),
(9, 2, 'Minyak Ikan Omega-3 Softgel (Botol 60)', 78000, 30,
 'Sumber asam lemak EPA dan DHA untuk membantu menjaga kesehatan jantung dan fungsi otak.',
 'p09_omega3.png', 'Obat Bebas',
 'Dewasa: 1-2 softgel sehari sesudah makan. Konsultasikan ke dokter bila sedang mengonsumsi obat pengencer darah.', 0),
(10, 2, 'Kapsul Ekstrak Temulawak (Botol 30)', 22000, 65,
 'Suplemen herbal dari rimpang temulawak untuk membantu memelihara kesehatan fungsi hati dan nafsu makan.',
 'p10_temulawak.png', 'Jamu/Herbal',
 'Dewasa: 2 kali sehari 1 kapsul, diminum sesudah makan.', 0),

-- ---------- Alat Kesehatan ----------
(11, 3, 'Termometer Digital Ujung Fleksibel', 35000, 45,
 'Termometer digital dengan ujung lentur, hasil pengukuran sekitar 60 detik, dilengkapi alarm dan memori pengukuran terakhir.',
 'p11_termometer.png', 'Non-Obat',
 'Cara pakai: tekan tombol power, letakkan ujung termometer di ketiak/mulut, tunggu hingga berbunyi, lalu baca hasil. Bersihkan ujung dengan alkohol 70% setelah dipakai.', 1),
(12, 3, 'Masker Medis 3 Ply Earloop (Box 50)', 28000, 100,
 'Masker sekali pakai 3 lapis dengan lapisan filter, nyaman dengan tali telinga elastis.',
 'p12_masker.png', 'Non-Obat',
 'Cara pakai: bagian berwarna menghadap ke luar, tekan kawat hidung agar rapat, ganti setiap 4 jam atau bila lembap. Hanya untuk sekali pakai.', 0),
(13, 3, 'Tensimeter Digital Lengan Atas', 325000, 12,
 'Alat ukur tekanan darah dan denyut nadi otomatis dengan manset lengan atas dan layar besar.',
 'p13_tensimeter.png', 'Non-Obat',
 'Cara pakai: duduk tenang 5 menit, pasang manset 2-3 cm di atas siku sejajar jantung, tekan START dan jangan berbicara selama pengukuran.', 1),
(14, 3, 'Kasa Steril 16 x 16 cm (Box 10)', 12000, 70,
 'Kain kasa steril untuk menutup dan membersihkan luka. Dikemas satuan agar tetap higienis.',
 'p14_kasa.png', 'Non-Obat',
 'Cara pakai: cuci tangan, bersihkan luka, buka kemasan tanpa menyentuh bagian kasa, tempelkan pada luka lalu fiksasi dengan plester. Ganti minimal 1 kali sehari.', 0),
(15, 3, 'Plester Luka Elastis (Isi 20)', 9500, 110,
 'Plester luka kain elastis yang lentur mengikuti gerak tubuh, cocok untuk luka kecil sehari-hari.',
 'p15_plester.png', 'Non-Obat',
 'Cara pakai: bersihkan dan keringkan area luka, tempelkan plester tanpa menyentuh bantalan, ganti setiap hari atau bila basah.', 0),

-- ---------- Perawatan Tubuh ----------
(16, 4, 'Hand Sanitizer Gel Alkohol 70% 100 ml', 18000, 85,
 'Gel pembersih tangan tanpa bilas dengan alkohol 70% dan lidah buaya agar tangan tidak kering.',
 'p16_sanitizer.png', 'Non-Obat',
 'Cara pakai: tuangkan secukupnya ke telapak tangan, ratakan ke seluruh permukaan tangan hingga kering (sekitar 20 detik). Jauhkan dari api.', 1),
(17, 4, 'Sabun Cair Antiseptik 250 ml', 24000, 60,
 'Sabun mandi cair antiseptik untuk membantu melindungi kulit dari kuman penyebab bau badan.',
 'p17_sabun.png', 'Non-Obat',
 'Cara pakai: basahi kulit, tuangkan sabun secukupnya, usap hingga berbusa lalu bilas dengan air bersih. Hindari kontak dengan mata.', 0),
(18, 4, 'Losion Pelembap Kulit Kering 200 ml', 45000, 35,
 'Losion dengan ceramide dan gliserin untuk melembapkan kulit kering dan bersisik.',
 'p18_losion.png', 'Non-Obat',
 'Cara pakai: oleskan secara merata pada kulit yang bersih 2 kali sehari, terutama setelah mandi.', 0),
(19, 4, 'Tabir Surya SPF 50 PA+++ 50 ml', 55000, 0,
 'Krim tabir surya ringan yang melindungi kulit dari sinar UVA dan UVB, tidak lengket.',
 'p19_sunscreen.png', 'Non-Obat',
 'Cara pakai: oleskan merata ke wajah dan leher 15 menit sebelum terpapar matahari, ulangi setiap 2-3 jam.', 0),
(20, 4, 'Minyak Telon Bayi 60 ml', 27000, 55,
 'Minyak tradisional campuran minyak kayu putih, adas, dan kelapa untuk menghangatkan tubuh bayi dan anak.',
 'p20_telon.png', 'Jamu/Herbal',
 'Oleskan secukupnya pada perut, dada, dan punggung bayi setelah mandi atau sebelum tidur. Hanya untuk pemakaian luar.', 0);

-- ---------------------------------------------------------------------
-- Contoh riwayat pesanan (agar dashboard langsung terisi)
-- ---------------------------------------------------------------------
INSERT INTO pesanan (id, nomor_pesanan, nama_pemesan, no_hp, metode_pengambilan, alamat, catatan,
                     subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal) VALUES
(1, CONCAT('INV-', DATE_FORMAT(NOW() - INTERVAL 5 DAY, '%Y%m%d'), '-001'), 'Dewi Lestari', '081234567801', 'Ambil di Tempat', NULL, NULL,
    50000, 2000, 0, 0, 52000, 'Selesai', NOW() - INTERVAL 5 DAY),
(2, CONCAT('INV-', DATE_FORMAT(NOW() - INTERVAL 3 DAY, '%Y%m%d'), '-001'), 'Bagus Pratama', '085712345678', 'Diantar', 'Jl. Melati No. 12, Bandung', 'Titip di pos satpam',
    360000, 2000, 10000, 36000, 336000, 'Selesai', NOW() - INTERVAL 3 DAY),
(3, CONCAT('INV-', DATE_FORMAT(NOW() - INTERVAL 1 DAY, '%Y%m%d'), '-001'), 'Sari Wulandari', '087812345670', 'Ambil di Tempat', NULL, NULL,
    35000, 2000, 0, 0, 37000, 'Dibatalkan', NOW() - INTERVAL 1 DAY),
(4, CONCAT('INV-', DATE_FORMAT(NOW() - INTERVAL 1 DAY, '%Y%m%d'), '-002'), 'Andi Saputra', '081398765432', 'Diantar', 'Perum Griya Asri Blok C2, Cimahi', NULL,
    72000, 2000, 10000, 0, 84000, 'Diproses', NOW() - INTERVAL 1 DAY);

INSERT INTO detail_pesanan (pesanan_id, produk_id, nama_produk, harga_satuan, jumlah, subtotal) VALUES
(1, 6,  'Vitamin C 500 mg Tablet Hisap (Botol 30)', 25000, 2, 50000),
(2, 13, 'Tensimeter Digital Lengan Atas',          325000, 1, 325000),
(2, 11, 'Termometer Digital Ujung Fleksibel',       35000, 1, 35000),
(3, 11, 'Termometer Digital Ujung Fleksibel',       35000, 1, 35000),
(4, 16, 'Hand Sanitizer Gel Alkohol 70% 100 ml',    18000, 2, 36000),
(4, 1,  'Parasetamol 500 mg Tablet (Strip 10)',      8500, 2, 17000),
(4, 15, 'Plester Luka Elastis (Isi 20)',             9500, 2, 19000);
