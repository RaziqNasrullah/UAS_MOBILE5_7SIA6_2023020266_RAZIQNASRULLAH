<?php
// GET pesanan/detail.php?id=1
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/pesanan_helper.php';
require_method('GET');

$id = int_param($_GET['id'] ?? null);
if ($id === null) {
    send_json(false, 'ID pesanan tidak valid.', null, 422);
}

try {
    $pesanan = find_pesanan(Database::getConnection(), $id);
    if (!$pesanan) {
        send_json(false, 'Pesanan tidak ditemukan.', null, 404);
    }
    send_json(true, 'Detail pesanan.', $pesanan);
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat detail pesanan: ' . $e->getMessage(), null, 500);
}
