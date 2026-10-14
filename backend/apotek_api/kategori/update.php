<?php
// POST kategori/update.php  body: { id, nama, deskripsi?, ikon? }
require_once __DIR__ . '/../helpers/response.php';
require_method('POST', 'PUT');

$in        = get_input();
$id        = int_param($in['id'] ?? null);
$nama      = str_input($in, 'nama');
$deskripsi = str_input($in, 'deskripsi');
$ikon      = str_input($in, 'ikon');

if ($id === null) {
    send_json(false, 'ID kategori tidak valid.', null, 422);
}
if ($nama === '') {
    send_json(false, 'Nama kategori wajib diisi.', null, 422);
}

try {
    $db = Database::getConnection();

    $ada = $db->prepare('SELECT id FROM kategori WHERE id = ?');
    $ada->execute([$id]);
    if (!$ada->fetch()) {
        send_json(false, 'Kategori tidak ditemukan.', null, 404);
    }

    $cek = $db->prepare('SELECT id FROM kategori WHERE LOWER(nama) = LOWER(?) AND id <> ? LIMIT 1');
    $cek->execute([$nama, $id]);
    if ($cek->fetch()) {
        send_json(false, "Kategori \"$nama\" sudah ada. Gunakan nama lain.", null, 409);
    }

    $stmt = $db->prepare('UPDATE kategori SET nama = ?, deskripsi = ?, ikon = ? WHERE id = ?');
    $stmt->execute([$nama, $deskripsi ?: null, $ikon ?: null, $id]);

    send_json(true, 'Kategori berhasil diperbarui.', ['id' => $id, 'nama' => $nama, 'deskripsi' => $deskripsi ?: null, 'ikon' => $ikon ?: null]);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        send_json(false, "Kategori \"$nama\" sudah ada.", null, 409);
    }
    send_json(false, 'Gagal memperbarui kategori: ' . $e->getMessage(), null, 500);
}
