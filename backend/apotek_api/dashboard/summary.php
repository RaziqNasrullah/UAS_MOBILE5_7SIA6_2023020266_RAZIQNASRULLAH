<?php
// GET dashboard/summary.php
// - total_pesanan       : semua pesanan (+ rincian per status)
// - total_pendapatan    : SUM(total) pesanan berstatus "Selesai" saja
// - produk_terlaris     : SUM(jumlah) detail_pesanan, pesanan "Dibatalkan" tidak dihitung (top 5)
// - pendapatan_harian   : pendapatan "Selesai" 7 hari terakhir
require_once __DIR__ . '/../helpers/response.php';
require_method('GET');

try {
    $db = Database::getConnection();

    $perStatus = ['Diproses' => 0, 'Selesai' => 0, 'Dibatalkan' => 0];
    foreach ($db->query('SELECT status, COUNT(*) AS n FROM pesanan GROUP BY status') as $r) {
        $perStatus[$r['status']] = (int) $r['n'];
    }

    $pendapatan = (float) $db->query("SELECT COALESCE(SUM(total), 0) FROM pesanan WHERE status = 'Selesai'")->fetchColumn();

    $terlaris = $db->query("SELECT dp.produk_id, dp.nama_produk, SUM(dp.jumlah) AS total_terjual,
                                   SUM(dp.subtotal) AS total_penjualan
                            FROM detail_pesanan dp
                            JOIN pesanan ps ON ps.id = dp.pesanan_id
                            WHERE ps.status <> 'Dibatalkan'
                            GROUP BY dp.produk_id, dp.nama_produk
                            ORDER BY total_terjual DESC, total_penjualan DESC
                            LIMIT 5")->fetchAll();
    foreach ($terlaris as &$t) {
        $t['produk_id']       = $t['produk_id'] === null ? null : (int) $t['produk_id'];
        $t['total_terjual']   = (int) $t['total_terjual'];
        $t['total_penjualan'] = (float) $t['total_penjualan'];
    }
    unset($t);

    // 7 hari terakhir (termasuk hari ini), hari tanpa transaksi = 0
    $harian = [];
    for ($i = 6; $i >= 0; $i--) {
        $harian[date('Y-m-d', strtotime("-$i day"))] = 0.0;
    }
    $stmt = $db->query("SELECT DATE(tanggal) AS tgl, SUM(total) AS pendapatan
                        FROM pesanan
                        WHERE status = 'Selesai' AND tanggal >= CURDATE() - INTERVAL 6 DAY
                        GROUP BY DATE(tanggal)");
    foreach ($stmt as $r) {
        if (array_key_exists($r['tgl'], $harian)) {
            $harian[$r['tgl']] = (float) $r['pendapatan'];
        }
    }
    $pendapatanHarian = [];
    foreach ($harian as $tgl => $nilai) {
        $pendapatanHarian[] = ['tanggal' => $tgl, 'pendapatan' => $nilai];
    }

    $produk = $db->query('SELECT COUNT(*) AS jumlah, COALESCE(SUM(stok = 0), 0) AS habis FROM produk')->fetch();

    send_json(true, 'Ringkasan penjualan.', [
        'total_pesanan'      => array_sum($perStatus),
        'pesanan_per_status' => $perStatus,
        'total_pendapatan'   => $pendapatan,
        'produk_terlaris'    => $terlaris,
        'pendapatan_harian'  => $pendapatanHarian,
        'jumlah_produk'      => (int) $produk['jumlah'],
        'produk_stok_habis'  => (int) $produk['habis'],
    ]);
} catch (PDOException $e) {
    send_json(false, 'Gagal memuat dashboard: ' . $e->getMessage(), null, 500);
}
