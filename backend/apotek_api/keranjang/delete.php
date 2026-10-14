<?php
// POST keranjang/delete.php  body: { id }
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/keranjang_helper.php';
require_method('POST', 'DELETE');

$in = get_input();
$id = int_param($in['id'] ?? ($_GET['id'] ?? null));
if ($id === null) {
    send_json(false, 'Item keranjang tidak valid.', null, 422);
}

try {
    $db = Database::getConnection();
    $stmt = $db->prepare('DELETE FROM keranjang WHERE id = ?');
    $stmt->execute([$id]);
    if ($stmt->rowCount() === 0) {
        send_json(false, 'Item keranjang tidak ditemukan.', null, 404);
    }
    send_json(true, 'Item dihapus dari keranjang.', keranjang_payload($db));
} catch (PDOException $e) {
    send_json(false, 'Gagal menghapus item: ' . $e->getMessage(), null, 500);
}
