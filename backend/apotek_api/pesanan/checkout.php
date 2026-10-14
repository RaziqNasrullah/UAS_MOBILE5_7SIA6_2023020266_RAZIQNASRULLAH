<?php
// POST pesanan/checkout.php
// body: { nama_pemesan, no_hp, metode_pengambilan, alamat?, catatan? }
// Item diambil dari tabel keranjang. Semua langkah dalam SATU transaksi:
// kunci stok (FOR UPDATE) -> validasi -> buat nomor INV -> simpan pesanan & detail
// -> kurangi stok -> kosongkan keranjang -> commit (atau rollback bila gagal).
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/pesanan_helper.php';
require_method('POST');

$in      = get_input();
$nama    = str_input($in, 'nama_pemesan');
$noHp    = preg_replace('/[\s-]/', '', str_input($in, 'no_hp'));
$metode  = str_input($in, 'metode_pengambilan');
$alamat  = str_input($in, 'alamat');
$catatan = str_input($in, 'catatan');

// ---- Validasi form ----
if ($nama === '') {
    send_json(false, 'Nama pemesan wajib diisi.', null, 422);
}
if (mb_strlen($nama) > 100) {
    send_json(false, 'Nama pemesan maksimal 100 karakter.', null, 422);
}
if (!preg_match('/^08[0-9]{8,11}$/', $noHp)) {
    send_json(false, 'Nomor HP harus berupa angka 10-13 digit dan diawali 08.', null, 422);
}
if (!in_array($metode, METODE_PENGAMBILAN, true)) {
    send_json(false, 'Metode pengambilan tidak valid.', null, 422);
}
if ($metode === 'Diantar' && $alamat === '') {
    send_json(false, 'Alamat pengantaran wajib diisi untuk metode Diantar.', null, 422);
}
if ($metode !== 'Diantar') {
    $alamat = '';
}

try {
    $db = Database::getConnection();
    $db->beginTransaction();

    // 1. Kunci baris produk yang ada di keranjang
    $items = $db->query('SELECT kr.produk_id, kr.jumlah, p.nama, p.harga, p.stok
                         FROM keranjang kr
                         JOIN produk p ON p.id = kr.produk_id
                         ORDER BY kr.id
                         FOR UPDATE')->fetchAll();
    if (!$items) {
        $db->rollBack();
        send_json(false, 'Keranjang masih kosong.', null, 422);
    }

    // 2. Validasi ulang stok di server
    $kurang = [];
    $subtotal = 0.0;
    foreach ($items as $it) {
        if ((int) $it['jumlah'] > (int) $it['stok']) {
            $kurang[] = "{$it['nama']} (stok {$it['stok']}, diminta {$it['jumlah']})";
        }
        $subtotal += (float) $it['harga'] * (int) $it['jumlah'];
    }
    if ($kurang) {
        $db->rollBack();
        send_json(false, 'Stok tidak mencukupi: ' . implode('; ', $kurang) . '. Silakan ubah jumlah di keranjang.', ['stok_kurang' => $kurang], 409);
    }

    // 3. Nomor pesanan otomatis INV-YYYYMMDD-NNN (reset tiap hari)
    $prefix = 'INV-' . date('Ymd') . '-';
    $q = $db->prepare('SELECT MAX(CAST(SUBSTRING(nomor_pesanan, 14) AS UNSIGNED))
                       FROM pesanan WHERE nomor_pesanan LIKE ? FOR UPDATE');
    $q->execute([$prefix . '%']);
    $urut = ((int) $q->fetchColumn()) + 1;
    $nomor = $prefix . str_pad((string) $urut, 3, '0', STR_PAD_LEFT);

    // 4. Simpan header pesanan
    $biaya = hitung_biaya($subtotal, $metode);
    $db->prepare('INSERT INTO pesanan
        (nomor_pesanan, nama_pemesan, no_hp, metode_pengambilan, alamat, catatan,
         subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'Diproses\', NOW())')
        ->execute([
            $nomor, $nama, $noHp, $metode, $alamat ?: null, $catatan ?: null,
            $biaya['subtotal'], $biaya['biaya_layanan'], $biaya['ongkir'], $biaya['diskon'], $biaya['total'],
        ]);
    $pesananId = (int) $db->lastInsertId();

    // 5. Simpan detail (snapshot nama & harga) + kurangi stok
    $insDetail = $db->prepare('INSERT INTO detail_pesanan
        (pesanan_id, produk_id, nama_produk, harga_satuan, jumlah, subtotal) VALUES (?, ?, ?, ?, ?, ?)');
    $kurangiStok = $db->prepare('UPDATE produk SET stok = stok - ? WHERE id = ? AND stok >= ?');
    foreach ($items as $it) {
        $harga  = (float) $it['harga'];
        $jumlah = (int) $it['jumlah'];
        $insDetail->execute([$pesananId, $it['produk_id'], $it['nama'], $harga, $jumlah, $harga * $jumlah]);
        $kurangiStok->execute([$jumlah, $it['produk_id'], $jumlah]);
        if ($kurangiStok->rowCount() !== 1) {
            throw new RuntimeException("Stok {$it['nama']} berubah saat checkout.");
        }
    }

    // 6. Kosongkan keranjang
    $db->exec('DELETE FROM keranjang');

    $db->commit();
    send_json(true, "Pesanan $nomor berhasil dibuat.", find_pesanan($db, $pesananId), 201);
} catch (Throwable $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    send_json(false, 'Checkout gagal, transaksi dibatalkan: ' . $e->getMessage(), null, 500);
}
