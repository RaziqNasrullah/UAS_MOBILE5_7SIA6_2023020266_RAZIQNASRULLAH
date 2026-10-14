<?php
require_once __DIR__ . '/helpers/response.php';

try {
    Database::getConnection()->query('SELECT 1');
    send_json(true, 'API Apotek HealthGwJirt aktif & database terhubung.', [
        'app'     => 'MyHealthGw',
        'version' => '1.0.0',
        'time'    => date('Y-m-d H:i:s'),
    ]);
} catch (PDOException $e) {
    send_json(false, 'API aktif, tetapi database belum terhubung: ' . $e->getMessage(), null, 500);
}
