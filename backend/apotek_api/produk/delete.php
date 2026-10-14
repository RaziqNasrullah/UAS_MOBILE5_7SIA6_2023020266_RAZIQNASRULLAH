<?php
// POST produk/delete.php  body: { id }
// Riwayat pesanan tetap aman karena detail_pesanan menyimpan snapshot nama & harga.
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/produk_validator.php';
require_method('POST', 'DELETE');

$in = get_input();
$id = int_param($in['id'] ?? ($_GET['id'] ?? null));
if ($id === null) {
    send_json(false, 'ID produk tidak valid.', null, 422);
}

try {
    $db = Database::getConnection();
    $produk = find_produk($db, $id);
    if (!$produk) {
        send_json(false, 'Produk tidak ditemukan.', null, 404);
    }

    $db->prepare('DELETE FROM produk WHERE id = ?')->execute([$id]);
    if ($produk['gambar'] && is_file(UPLOAD_DIR . $produk['gambar'])) {
        @unlink(UPLOAD_DIR . $produk['gambar']);
    }

    send_json(true, "Produk \"{$produk['nama']}\" berhasil dihapus.", ['id' => $id]);
} catch (PDOException $e) {
    send_json(false, 'Gagal menghapus produk: ' . $e->getMessage(), null, 500);
}
