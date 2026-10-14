<?php
/**
 * Konfigurasi koneksi database & konstanta aplikasi.
 * Sesuaikan DB_USER / DB_PASS bila MySQL XAMPP Anda memakai password.
 */

date_default_timezone_set('Asia/Jakarta');

define('DB_HOST', '127.0.0.1');
define('DB_PORT', '3306');
define('DB_NAME', 'db_apotek');
define('DB_USER', 'root');
define('DB_PASS', '');

// Aturan biaya checkout (samakan dengan lib/app/data/services/api_config.dart)
define('BIAYA_LAYANAN', 2000);
define('ONGKIR_DIANTAR', 10000);
define('MIN_SUBTOTAL_DISKON', 150000);
define('PERSEN_DISKON', 10);

// Upload gambar produk
define('UPLOAD_DIR', __DIR__ . '/../uploads/');
define('MAX_UPLOAD_BYTES', 2 * 1024 * 1024);

class Database
{
    private static ?PDO $conn = null;

    public static function getConnection(): PDO
    {
        if (self::$conn === null) {
            $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
            self::$conn = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_STRINGIFY_FETCHES  => false,
            ]);
            self::$conn->exec("SET time_zone = '+07:00'");
        }
        return self::$conn;
    }
}
