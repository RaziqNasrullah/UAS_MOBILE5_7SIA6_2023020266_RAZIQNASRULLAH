<?php
// GET produk/read.php?search=para&kategori_id=1&unggulan=1&limit=10&sort=terbaru
// Nama kategori diambil lewat JOIN.
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/produk_validator.php';
require_method('GET');

try {
    $db = Database::getConnection();

    $where  = [];
    $params = [];

    $search = trim((string) ($_GET['search'] ?? ''));
    if ($search !== '') {
        $where[]  = 'p.nama LIKE ?';
        $params[] = '%' . $search . '%';
    }
    $kategoriId = int_param($_GET['kategori_id'] ?? null);
    if ($kategoriId !== null && $kategoriId > 0) {
        $where[]  = 'p.kategori_id = ?';
        $params[] = $kategoriId;
    }
    if (($_GET['unggulan'] ?? '') === '1') {
        $where[] = 'p.is_unggulan = 1';
    }

    $sql = PRODUK_SELECT;
    if ($where) {
        $sql .= ' WHERE ' . implode(' AND ', $where);
    }
    $sql .= ($_GET['sort'] ?? '') === 'terbaru' ? ' ORDER BY p.created_at DESC, p.id DESC' : ' ORDER BY p.nama ASC';

    $limit = int_param($_GET['limit'] ?? null);
    if ($limit !== null && $limit > 0) {
        $sql .= ' LIMIT ' . min($limit, 100);
    }

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $rows = array_map('cast_produk', $stmt->fetchAll());

    send_json(true, count($rows) . ' produk ditemukan.', $rows);
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat produk: ' . $e->getMessage(), null, 500);
}
