<?php
/** Ambil seluruh isi keranjang + data produk (JOIN) beserta ringkasan. */
function keranjang_payload(PDO $db): array
{
    $rows = $db->query('SELECT kr.id, kr.produk_id, kr.jumlah, kr.created_at,
                               p.nama, p.harga, p.stok, p.gambar, p.golongan_obat,
                               k.nama AS nama_kategori
                        FROM keranjang kr
                        JOIN produk p   ON p.id = kr.produk_id
                        JOIN kategori k ON k.id = p.kategori_id
                        ORDER BY kr.created_at ASC, kr.id ASC')->fetchAll();

    $total = 0;
    $qty   = 0;
    foreach ($rows as &$r) {
        $r['id']        = (int) $r['id'];
        $r['produk_id'] = (int) $r['produk_id'];
        $r['jumlah']    = (int) $r['jumlah'];
        $r['harga']     = (float) $r['harga'];
        $r['stok']      = (int) $r['stok'];
        $r['subtotal']  = $r['harga'] * $r['jumlah'];
        $total += $r['subtotal'];
        $qty   += $r['jumlah'];
    }
    return ['items' => $rows, 'total_item' => $qty, 'subtotal' => $total];
}
