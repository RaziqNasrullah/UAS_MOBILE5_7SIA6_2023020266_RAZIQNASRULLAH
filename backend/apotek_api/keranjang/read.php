<?php
// GET keranjang/read.php
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/keranjang_helper.php';
require_method('GET');

try {
    send_json(true, 'Isi keranjang.', keranjang_payload(Database::getConnection()));
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat keranjang: ' . $e->getMessage(), null, 500);
}
