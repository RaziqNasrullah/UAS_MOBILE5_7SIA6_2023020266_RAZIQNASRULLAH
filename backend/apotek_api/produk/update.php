<?php
// POST produk/update.php  body: { id, ...field produk }
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/produk_validator.php';
require_method('POST', 'PUT');

try {
    $db = Database::getConnection();
    $in = get_input();
    $id = int_param($in['id'] ?? null);
    if ($id === null) {
        send_json(false, 'ID produk tidak valid.', null, 422);
    }
    $lama = find_produk($db, $id);
    if (!$lama) {
        send_json(false, 'Produk tidak ditemukan.', null, 404);
    }

    [$d, $error] = validate_produk($db, $in);
    if ($error) {
        send_json(false, $error, null, 422);
    }
    // Jika gambar tidak dikirim, pertahankan gambar lama
    if ($d['gambar'] === null && !array_key_exists('gambar', $in)) {
        $d['gambar'] = $lama['gambar'];
    }

    $stmt = $db->prepare('UPDATE produk SET
        kategori_id = ?, nama = ?, harga = ?, stok = ?, deskripsi = ?, gambar = ?,
        golongan_obat = ?, aturan_pakai = ?, is_unggulan = ?
        WHERE id = ?');
    $stmt->execute([
        $d['kategori_id'], $d['nama'], $d['harga'], $d['stok'], $d['deskripsi'], $d['gambar'],
        $d['golongan_obat'], $d['aturan_pakai'], $d['is_unggulan'], $id,
    ]);

    // Hapus file gambar lama bila diganti
    if ($lama['gambar'] && $lama['gambar'] !== $d['gambar'] && is_file(UPLOAD_DIR . $lama['gambar'])) {
        @unlink(UPLOAD_DIR . $lama['gambar']);
    }

    send_json(true, 'Produk berhasil diperbarui.', find_produk($db, $id));
} catch (PDOException $e) {
    send_json(false, 'Gagal memperbarui produk: ' . $e->getMessage(), null, 500);
}
