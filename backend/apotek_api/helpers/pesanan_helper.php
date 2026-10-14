<?php
/** Ambil pesanan lengkap beserta item-itemnya. */
function find_pesanan(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM pesanan WHERE id = ?');
    $stmt->execute([$id]);
    $pesanan = $stmt->fetch();
    if (!$pesanan) {
        return null;
    }
    $pesanan = cast_pesanan($pesanan);

    $d = $db->prepare('SELECT * FROM detail_pesanan WHERE pesanan_id = ? ORDER BY id ASC');
    $d->execute([$id]);
    $pesanan['items'] = array_map('cast_detail', $d->fetchAll());
    $pesanan['jumlah_item'] = array_sum(array_column($pesanan['items'], 'jumlah'));
    return $pesanan;
}

/** Hitung rincian biaya (aturan sama dengan aplikasi Flutter). */
function hitung_biaya(float $subtotal, string $metode): array
{
    $layanan = (float) BIAYA_LAYANAN;
    $ongkir  = $metode === 'Diantar' ? (float) ONGKIR_DIANTAR : 0.0;
    $diskon  = $subtotal >= MIN_SUBTOTAL_DISKON ? round($subtotal * PERSEN_DISKON / 100) : 0.0;
    $total   = $subtotal + $layanan + $ongkir - $diskon;
    return [
        'subtotal'      => $subtotal,
        'biaya_layanan' => $layanan,
        'ongkir'        => $ongkir,
        'diskon'        => (float) $diskon,
        'total'         => $total,
    ];
}
