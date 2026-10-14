<?php
// POST kategori/create.php  body: { nama, deskripsi?, ikon? }
require_once __DIR__ . '/../helpers/response.php';
require_method('POST');

$in        = get_input();
$nama      = str_input($in, 'nama');
$deskripsi = str_input($in, 'deskripsi');
$ikon      = str_input($in, 'ikon');

if ($nama === '') {
    send_json(false, 'Nama kategori wajib diisi.', null, 422);
}
if (mb_strlen($nama) > 100) {
    send_json(false, 'Nama kategori maksimal 100 karakter.', null, 422);
}

try {
    $db = Database::getConnection();

    // Cek duplikat (case-insensitive)
    $cek = $db->prepare('SELECT id FROM kategori WHERE LOWER(nama) = LOWER(?) LIMIT 1');
    $cek->execute([$nama]);
    if ($cek->fetch()) {
        send_json(false, "Kategori \"$nama\" sudah ada. Gunakan nama lain.", null, 409);
    }

    $stmt = $db->prepare('INSERT INTO kategori (nama, deskripsi, ikon) VALUES (?, ?, ?)');
    $stmt->execute([$nama, $deskripsi ?: null, $ikon ?: null]);
    $id = (int) $db->lastInsertId();

    send_json(true, 'Kategori berhasil ditambahkan.', [
        'id' => $id, 'nama' => $nama, 'deskripsi' => $deskripsi ?: null, 'ikon' => $ikon ?: null, 'jumlah_produk' => 0,
    ], 201);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        send_json(false, "Kategori \"$nama\" sudah ada.", null, 409);
    }
    send_json(false, 'Gagal menambah kategori: ' . $e->getMessage(), null, 500);
}
