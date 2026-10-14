import '../data/services/api_config.dart';
import '../models/pesanan.dart';

/// Rincian biaya checkout (aturan sama dengan server).
class RincianBiaya {
  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;

  const RincianBiaya({
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
  });

  /// Total = subtotal + biaya layanan + ongkir - diskon
  double get total => subtotal + biayaLayanan + ongkir - diskon;

  bool get dapatDiskon => diskon > 0;

  /// Kekurangan belanja agar mendapat diskon.
  double get kurangUntukDiskon =>
      dapatDiskon ? 0 : (ApiConfig.minSubtotalDiskon - subtotal).clamp(0, double.infinity);

  static RincianBiaya hitung(double subtotal, String metode) {
    if (subtotal <= 0) {
      return const RincianBiaya(subtotal: 0, biayaLayanan: 0, ongkir: 0, diskon: 0);
    }
    return RincianBiaya(
      subtotal: subtotal,
      biayaLayanan: ApiConfig.biayaLayanan,
      ongkir: metode == MetodePengambilan.diantar ? ApiConfig.ongkirDiantar : 0,
      diskon: subtotal >= ApiConfig.minSubtotalDiskon
          ? (subtotal * ApiConfig.persenDiskon / 100).roundToDouble()
          : 0,
    );
  }
}
