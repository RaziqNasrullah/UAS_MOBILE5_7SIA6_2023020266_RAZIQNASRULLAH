<?php
// POST keranjang/clear.php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/keranjang_helper.php';
require_method('POST', 'DELETE');

try {
    $db = Database::getConnection();
    $db->exec('DELETE FROM keranjang');
    send_json(true, 'Keranjang dikosongkan.', keranjang_payload($db));
} catch (PDOException $e) {
    send_json(false, 'Gagal mengosongkan keranjang: ' . $e->getMessage(), null, 500);
}
