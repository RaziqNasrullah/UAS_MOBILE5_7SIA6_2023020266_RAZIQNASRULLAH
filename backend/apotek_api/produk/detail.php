<?php
// GET produk/detail.php?id=1
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/produk_validator.php';
require_method('GET');

$id = int_param($_GET['id'] ?? null);
if ($id === null) {
    send_json(false, 'ID produk tidak valid.', null, 422);
}

try {
    $produk = find_produk(Database::getConnection(), $id);
    if (!$produk) {
        send_json(false, 'Produk tidak ditemukan.', null, 404);
    }
    send_json(true, 'Detail produk.', $produk);
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat detail produk: ' . $e->getMessage(), null, 500);
}
