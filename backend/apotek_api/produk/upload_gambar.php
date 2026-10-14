<?php
// POST multipart produk/upload_gambar.php  field file: "gambar"
// Mengembalikan { "gambar": "<nama_file>" } untuk disimpan di kolom produk.gambar
require_once __DIR__ . '/../helpers/response.php';
require_method('POST');

if (!isset($_FILES['gambar'])) {
    send_json(false, 'File gambar tidak ditemukan pada request (field "gambar").', null, 422);
}

$file = $_FILES['gambar'];
if ($file['error'] !== UPLOAD_ERR_OK) {
    $pesan = in_array($file['error'], [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true)
        ? 'Ukuran gambar melebihi batas server.'
        : 'Upload gambar gagal (kode ' . $file['error'] . ').';
    send_json(false, $pesan, null, 422);
}
if ($file['size'] > MAX_UPLOAD_BYTES) {
    send_json(false, 'Ukuran gambar maksimal 2 MB.', null, 422);
}

$info = @getimagesize($file['tmp_name']);
$ekstensi = [IMAGETYPE_JPEG => 'jpg', IMAGETYPE_PNG => 'png', IMAGETYPE_WEBP => 'webp'];
if ($info === false || !isset($ekstensi[$info[2]])) {
    send_json(false, 'Format gambar harus JPG, PNG, atau WEBP.', null, 422);
}

try {
    if (!is_dir(UPLOAD_DIR) && !mkdir(UPLOAD_DIR, 0775, true)) {
        throw new RuntimeException('Folder uploads tidak dapat dibuat.');
    }
    $nama = 'prd_' . date('YmdHis') . '_' . bin2hex(random_bytes(4)) . '.' . $ekstensi[$info[2]];
    if (!move_uploaded_file($file['tmp_name'], UPLOAD_DIR . $nama)) {
        throw new RuntimeException('Gagal menyimpan file ke folder uploads.');
    }
    send_json(true, 'Gambar berhasil diunggah.', ['gambar' => $nama], 201);
} catch (Throwable $e) {
    send_json(false, 'Gagal mengunggah gambar: ' . $e->getMessage(), null, 500);
}
