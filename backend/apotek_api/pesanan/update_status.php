<?php
// POST pesanan/update_status.php  body: { id, status: "Selesai" | "Dibatalkan" }
// Hanya pesanan berstatus "Diproses" yang dapat diubah.
// Jika dibatalkan, stok produk dikembalikan dalam satu transaksi.
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/pesanan_helper.php';
require_method('POST', 'PUT');

$in     = get_input();
$id     = int_param($in['id'] ?? null);
$status = str_input($in, 'status');

if ($id === null) {
    send_json(false, 'ID pesanan tidak valid.', null, 422);
}
if (!in_array($status, ['Selesai', 'Dibatalkan'], true)) {
    send_json(false, 'Status baru harus "Selesai" atau "Dibatalkan".', null, 422);
}

try {
    $db = Database::getConnection();
    $db->beginTransaction();

    $stmt = $db->prepare('SELECT id, nomor_pesanan, status FROM pesanan WHERE id = ? FOR UPDATE');
    $stmt->execute([$id]);
    $pesanan = $stmt->fetch();
    if (!$pesanan) {
        $db->rollBack();
        send_json(false, 'Pesanan tidak ditemukan.', null, 404);
    }
    if ($pesanan['status'] !== 'Diproses') {
        $db->rollBack();
        send_json(false, "Pesanan {$pesanan['nomor_pesanan']} sudah berstatus {$pesanan['status']} dan tidak dapat diubah lagi.", null, 409);
    }

    if ($status === 'Dibatalkan') {
        // Kembalikan stok (produk yang sudah dihapus dilewati)
        $db->prepare('UPDATE produk p
                      JOIN detail_pesanan dp ON dp.produk_id = p.id
                      SET p.stok = p.stok + dp.jumlah
                      WHERE dp.pesanan_id = ?')->execute([$id]);
    }

    $db->prepare('UPDATE pesanan SET status = ? WHERE id = ?')->execute([$status, $id]);
    $db->commit();

    $pesan = $status === 'Dibatalkan'
        ? "Pesanan {$pesanan['nomor_pesanan']} dibatalkan dan stok dikembalikan."
        : "Pesanan {$pesanan['nomor_pesanan']} ditandai selesai.";
    send_json(true, $pesan, find_pesanan($db, $id));
} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    send_json(false, 'Gagal mengubah status pesanan: ' . $e->getMessage(), null, 500);
}
