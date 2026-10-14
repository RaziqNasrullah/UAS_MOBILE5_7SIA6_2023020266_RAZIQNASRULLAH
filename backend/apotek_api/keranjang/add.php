<?php
// POST keranjang/add.php  body: { produk_id, jumlah? = 1 }
// Jika produk sudah ada di keranjang, jumlahnya ditambah (tanpa melebihi stok).
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/keranjang_helper.php';
require_method('POST');

$in       = get_input();
$produkId = int_param($in['produk_id'] ?? null);
$jumlah   = int_param($in['jumlah'] ?? 1) ?? 1;

if ($produkId === null) {
    send_json(false, 'Produk tidak valid.', null, 422);
}
if ($jumlah < 1) {
    send_json(false, 'Jumlah minimal 1.', null, 422);
}

try {
    $db = Database::getConnection();
    $db->beginTransaction();

    $p = $db->prepare('SELECT nama, stok FROM produk WHERE id = ? FOR UPDATE');
    $p->execute([$produkId]);
    $produk = $p->fetch();
    if (!$produk) {
        $db->rollBack();
        send_json(false, 'Produk tidak ditemukan.', null, 404);
    }
    $stok = (int) $produk['stok'];
    if ($stok <= 0) {
        $db->rollBack();
        send_json(false, "Stok {$produk['nama']} habis.", null, 409);
    }

    $k = $db->prepare('SELECT id, jumlah FROM keranjang WHERE produk_id = ? FOR UPDATE');
    $k->execute([$produkId]);
    $item = $k->fetch();
    $baru = ($item ? (int) $item['jumlah'] : 0) + $jumlah;

    if ($baru > $stok) {
        $db->rollBack();
        send_json(false, "Jumlah melebihi stok. Stok {$produk['nama']} tersisa $stok" . ($item ? " dan sudah ada {$item['jumlah']} di keranjang." : '.'), null, 409);
    }

    if ($item) {
        $db->prepare('UPDATE keranjang SET jumlah = ? WHERE id = ?')->execute([$baru, $item['id']]);
    } else {
        $db->prepare('INSERT INTO keranjang (produk_id, jumlah) VALUES (?, ?)')->execute([$produkId, $baru]);
    }
    $db->commit();

    send_json(true, "{$produk['nama']} ditambahkan ke keranjang.", keranjang_payload($db));
} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    send_json(false, 'Gagal menambah ke keranjang: ' . $e->getMessage(), null, 500);
}
