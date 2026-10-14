/// Konfigurasi koneksi ke REST API PHP (XAMPP) & konstanta bisnis.
///
/// Ganti [baseUrl] sesuai perangkat yang dipakai:
/// - Emulator Android : http://10.0.2.2/apotek_api
/// - HP fisik         : `http://<IP-LAN-laptop>/apotek_api` (mis. http://192.168.1.10/apotek_api)
///
/// Bisa juga tanpa mengubah kode:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10/apotek_api`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/apotek_api',
  );

  /// Batas waktu tiap request sebelum dianggap server tidak merespons.
  static const Duration timeout = Duration(seconds: 15);

  /// URL lengkap gambar produk dari nama file di kolom `produk.gambar`.
  static String? imageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;
    if (fileName.startsWith('http')) return fileName;
    return '$baseUrl/uploads/$fileName';
  }

  // ---------------- Identitas toko ----------------
  static const String namaAplikasi = 'MyHealthGw';
  static const String namaToko = 'HealthGwJirt';
  static const String taglineToko = 'Your Personal Health Companion';
  static const String alamatToko = 'Apotek Digital HealthGwJirt';
  static const String pembuat = 'RAZIQNASRULLAH — 7SIA6';

  // ---------------- Aturan biaya checkout ----------------
  // (samakan dengan backend/apotek_api/config/database.php)
  static const double biayaLayanan = 2000;
  static const double ongkirDiantar = 10000;
  static const double minSubtotalDiskon = 150000;
  static const double persenDiskon = 10;
}
