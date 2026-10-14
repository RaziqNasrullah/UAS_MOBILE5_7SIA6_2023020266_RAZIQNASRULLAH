<?php
// GET kategori/read.php            -> semua kategori (+ jumlah produk)
// GET kategori/read.php?id=1       -> satu kategori
require_once __DIR__ . '/../helpers/response.php';
require_method('GET');

try {
    $db = Database::getConnection();
    $id = int_param($_GET['id'] ?? null);

    $sql = 'SELECT k.id, k.nama, k.deskripsi, k.ikon, k.created_at, k.updated_at,
                   COUNT(p.id) AS jumlah_produk
            FROM kategori k
            LEFT JOIN produk p ON p.kategori_id = k.id';
    if ($id !== null) {
        $stmt = $db->prepare($sql . ' WHERE k.id = ? GROUP BY k.id');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) {
            send_json(false, 'Kategori tidak ditemukan.', null, 404);
        }
        $row['id'] = (int) $row['id'];
        $row['jumlah_produk'] = (int) $row['jumlah_produk'];
        send_json(true, 'Detail kategori.', $row);
    }

    $rows = $db->query($sql . ' GROUP BY k.id ORDER BY k.id ASC')->fetchAll();
    foreach ($rows as &$r) {
        $r['id'] = (int) $r['id'];
        $r['jumlah_produk'] = (int) $r['jumlah_produk'];
    }
    send_json(true, count($rows) . ' kategori ditemukan.', $rows);
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat kategori: ' . $e->getMessage(), null, 500);
}
