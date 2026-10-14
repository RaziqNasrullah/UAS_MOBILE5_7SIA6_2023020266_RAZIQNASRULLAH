<?php
// POST keranjang/update_qty.php  body: { id, jumlah }
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/keranjang_helper.php';
require_method('POST', 'PUT');

$in     = get_input();
$id     = int_param($in['id'] ?? null);
$jumlah = int_param($in['jumlah'] ?? null);

if ($id === null) {
    send_json(false, 'Item keranjang tidak valid.', null, 422);
}
if ($jumlah === null || $jumlah < 1) {
    send_json(false, 'Jumlah minimal 1. Gunakan tombol hapus untuk menghapus item.', null, 422);
}

try {
    $db = Database::getConnection();
    $stmt = $db->prepare('SELECT kr.id, p.nama, p.stok FROM keranjang kr JOIN produk p ON p.id = kr.produk_id WHERE kr.id = ?');
    $stmt->execute([$id]);
    $item = $stmt->fetch();
    if (!$item) {
        send_json(false, 'Item keranjang tidak ditemukan.', null, 404);
    }
    if ($jumlah > (int) $item['stok']) {
        send_json(false, "Jumlah melebihi stok. Stok {$item['nama']} hanya {$item['stok']}.", ['stok' => (int) $item['stok']], 409);
    }

    $db->prepare('UPDATE keranjang SET jumlah = ? WHERE id = ?')->execute([$jumlah, $id]);
    send_json(true, 'Jumlah diperbarui.', keranjang_payload($db));
} catch (PDOException $e) {
    send_json(false, 'Gagal memperbarui jumlah: ' . $e->getMessage(), null, 500);
}
