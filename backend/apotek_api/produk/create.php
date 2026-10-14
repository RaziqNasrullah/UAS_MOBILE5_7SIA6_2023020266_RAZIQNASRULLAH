<?php
// POST produk/create.php
// body: { kategori_id, nama, harga, stok, deskripsi, gambar?, golongan_obat, aturan_pakai, is_unggulan? }
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/produk_validator.php';
require_method('POST');

try {
    $db = Database::getConnection();
    [$d, $error] = validate_produk($db, get_input());
    if ($error) {
        send_json(false, $error, null, 422);
    }

    $stmt = $db->prepare('INSERT INTO produk
        (kategori_id, nama, harga, stok, deskripsi, gambar, golongan_obat, aturan_pakai, is_unggulan)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $stmt->execute([
        $d['kategori_id'], $d['nama'], $d['harga'], $d['stok'], $d['deskripsi'],
        $d['gambar'], $d['golongan_obat'], $d['aturan_pakai'], $d['is_unggulan'],
    ]);

    send_json(true, 'Produk berhasil ditambahkan.', find_produk($db, (int) $db->lastInsertId()), 201);
} catch (PDOException $e) {
    send_json(false, 'Gagal menambah produk: ' . $e->getMessage(), null, 500);
}
