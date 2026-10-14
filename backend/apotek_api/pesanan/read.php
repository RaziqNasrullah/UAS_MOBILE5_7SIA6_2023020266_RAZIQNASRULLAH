<?php
// GET pesanan/read.php?status=Diproses   (status opsional)
// Urut dari pesanan terbaru.
require_once __DIR__ . '/../helpers/response.php';
require_method('GET');

try {
    $db = Database::getConnection();
    $sql = 'SELECT ps.*, COALESCE(SUM(dp.jumlah), 0) AS jumlah_item
            FROM pesanan ps
            LEFT JOIN detail_pesanan dp ON dp.pesanan_id = ps.id';
    $params = [];
    $status = trim((string) ($_GET['status'] ?? ''));
    if ($status !== '') {
        if (!in_array($status, STATUS_PESANAN, true)) {
            send_json(false, 'Filter status tidak valid.', null, 422);
        }
        $sql .= ' WHERE ps.status = ?';
        $params[] = $status;
    }
    $sql .= ' GROUP BY ps.id ORDER BY ps.tanggal DESC, ps.id DESC';

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $rows = array_map('cast_pesanan', $stmt->fetchAll());
    send_json(true, count($rows) . ' pesanan ditemukan.', $rows);
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat riwayat pesanan: ' . $e->getMessage(), null, 500);
}
