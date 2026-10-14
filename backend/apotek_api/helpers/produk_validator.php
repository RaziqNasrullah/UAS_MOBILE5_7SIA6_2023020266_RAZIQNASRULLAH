<?php
/**
 * Validasi input produk (dipakai create.php & update.php).
 * Mengembalikan [array $data, ?string $error].
 */
function validate_produk(PDO $db, array $in): array
{
    $data = [
        'kategori_id'   => int_param($in['kategori_id'] ?? null),
        'nama'          => str_input($in, 'nama'),
        'harga'         => $in['harga'] ?? null,
        'stok'          => $in['stok'] ?? null,
        'deskripsi'     => str_input($in, 'deskripsi'),
        'gambar'        => str_input($in, 'gambar'),
        'golongan_obat' => str_input($in, 'golongan_obat'),
        'aturan_pakai'  => str_input($in, 'aturan_pakai'),
        'is_unggulan'   => !empty($in['is_unggulan']) && $in['is_unggulan'] !== 'false' ? 1 : 0,
    ];

    if ($data['nama'] === '') {
        return [$data, 'Nama produk wajib diisi.'];
    }
    if (mb_strlen($data['nama']) > 150) {
        return [$data, 'Nama produk maksimal 150 karakter.'];
    }
    if ($data['kategori_id'] === null) {
        return [$data, 'Kategori wajib dipilih.'];
    }
    $k = $db->prepare('SELECT id FROM kategori WHERE id = ?');
    $k->execute([$data['kategori_id']]);
    if (!$k->fetch()) {
        return [$data, 'Kategori yang dipilih tidak ditemukan.'];
    }
    if (!is_numeric($data['harga']) || (float) $data['harga'] <= 0) {
        return [$data, 'Harga wajib berupa angka lebih dari 0.'];
    }
    $data['harga'] = (float) $data['harga'];
    if (filter_var($data['stok'], FILTER_VALIDATE_INT) === false || (int) $data['stok'] < 0) {
        return [$data, 'Stok wajib berupa bilangan bulat minimal 0.'];
    }
    $data['stok'] = (int) $data['stok'];
    if ($data['deskripsi'] === '') {
        return [$data, 'Deskripsi produk wajib diisi.'];
    }
    if (!in_array($data['golongan_obat'], GOLONGAN_OBAT, true)) {
        return [$data, 'Golongan obat tidak valid.'];
    }
    if ($data['aturan_pakai'] === '') {
        return [$data, 'Aturan pakai / dosis wajib diisi.'];
    }
    if ($data['gambar'] !== '' && basename($data['gambar']) !== $data['gambar']) {
        return [$data, 'Nama file gambar tidak valid.'];
    }
    $data['gambar'] = $data['gambar'] ?: null;
    return [$data, null];
}

const PRODUK_SELECT = 'SELECT p.*, k.nama AS nama_kategori
                       FROM produk p
                       JOIN kategori k ON p.kategori_id = k.id';

function find_produk(PDO $db, int $id): ?array
{
    $stmt = $db->prepare(PRODUK_SELECT . ' WHERE p.id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    return $row ? cast_produk($row) : null;
}
