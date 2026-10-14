<?php
// POST kategori/delete.php  body: { id }
// Ditolak jika kategori masih memiliki produk.
require_once __DIR__ . '/../helpers/response.php';
require_method('POST', 'DELETE');

$in = get_input();
$id = int_param($in['id'] ?? ($_GET['id'] ?? null));
if ($id === null) {
    send_json(false, 'ID kategori tidak valid.', null, 422);
}

try {
    $db = Database::getConnection();

    $k = $db->prepare('SELECT nama FROM kategori WHERE id = ?');
    $k->execute([$id]);
    $kategori = $k->fetch();
    if (!$kategori) {
        send_json(false, 'Kategori tidak ditemukan.', null, 404);
    }

    $c = $db->prepare('SELECT COUNT(*) FROM produk WHERE kategori_id = ?');
    $c->execute([$id]);
    $jumlah = (int) $c->fetchColumn();
    if ($jumlah > 0) {
        send_json(false, "Kategori \"{$kategori['nama']}\" tidak dapat dihapus karena masih memiliki $jumlah produk. Pindahkan atau hapus produknya terlebih dahulu.", ['jumlah_produk' => $jumlah], 409);
    }

    $db->prepare('DELETE FROM kategori WHERE id = ?')->execute([$id]);
    send_json(true, "Kategori \"{$kategori['nama']}\" berhasil dihapus.", ['id' => $id]);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        send_json(false, 'Kategori masih dipakai oleh produk sehingga tidak dapat dihapus.', null, 409);
    }
    send_json(false, 'Gagal menghapus kategori: ' . $e->getMessage(), null, 500);
}
