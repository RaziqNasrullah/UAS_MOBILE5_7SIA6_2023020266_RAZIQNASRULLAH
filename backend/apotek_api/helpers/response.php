<?php
/**
 * Helper respons JSON seragam:
 * { "success": true|false, "message": "...", "data": ... }
 */

require_once __DIR__ . '/../config/database.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Jangan tampilkan warning PHP sebagai HTML (merusak JSON)
ini_set('display_errors', '0');
error_reporting(E_ALL);

set_exception_handler(function (Throwable $e) {
    error_log('[apotek_api] ' . $e->getMessage());
    if ($e instanceof PDOException) {
        send_json(false, 'Gagal terhubung / memproses database. Pastikan MySQL XAMPP aktif dan db_apotek sudah di-import.', null, 500);
    }
    send_json(false, 'Terjadi kesalahan pada server: ' . $e->getMessage(), null, 500);
});

function send_json(bool $success, string $message, $data = null, int $code = 200): void
{
    http_response_code($code);
    echo json_encode(
        ['success' => $success, 'message' => $message, 'data' => $data],
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRESERVE_ZERO_FRACTION
    );
    exit;
}

/** Hanya izinkan method tertentu. */
function require_method(string ...$methods): void
{
    $m = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    if (!in_array($m, $methods, true)) {
        send_json(false, 'Method ' . $m . ' tidak diizinkan. Gunakan ' . implode('/', $methods) . '.', null, 405);
    }
}

/** Ambil body request: JSON atau form-urlencoded/multipart. */
function get_input(): array
{
    $raw = file_get_contents('php://input');
    if ($raw !== false && $raw !== '') {
        $json = json_decode($raw, true);
        if (is_array($json)) {
            return $json;
        }
    }
    return $_POST ?: [];
}

function str_input(array $in, string $key): string
{
    return isset($in[$key]) ? trim((string) $in[$key]) : '';
}

function int_param($value): ?int
{
    if ($value === null || $value === '') {
        return null;
    }
    $v = filter_var($value, FILTER_VALIDATE_INT);
    return $v === false ? null : $v;
}

/** Ubah tipe kolom numerik produk agar JSON rapi. */
function cast_produk(array $p): array
{
    $p['id']          = (int) $p['id'];
    $p['kategori_id'] = (int) $p['kategori_id'];
    $p['harga']       = (float) $p['harga'];
    $p['stok']        = (int) $p['stok'];
    $p['is_unggulan'] = (int) $p['is_unggulan'];
    return $p;
}

function cast_pesanan(array $p): array
{
    $p['id'] = (int) $p['id'];
    foreach (['subtotal', 'biaya_layanan', 'ongkir', 'diskon', 'total'] as $k) {
        $p[$k] = (float) $p[$k];
    }
    if (isset($p['jumlah_item'])) {
        $p['jumlah_item'] = (int) $p['jumlah_item'];
    }
    return $p;
}

function cast_detail(array $d): array
{
    $d['id']           = (int) $d['id'];
    $d['pesanan_id']   = (int) $d['pesanan_id'];
    $d['produk_id']    = $d['produk_id'] === null ? null : (int) $d['produk_id'];
    $d['harga_satuan'] = (float) $d['harga_satuan'];
    $d['jumlah']       = (int) $d['jumlah'];
    $d['subtotal']     = (float) $d['subtotal'];
    return $d;
}

const GOLONGAN_OBAT = ['Obat Bebas', 'Obat Bebas Terbatas', 'Obat Keras', 'Jamu/Herbal', 'Non-Obat'];
const METODE_PENGAMBILAN = ['Ambil di Tempat', 'Diantar'];
const STATUS_PESANAN = ['Diproses', 'Selesai', 'Dibatalkan'];
