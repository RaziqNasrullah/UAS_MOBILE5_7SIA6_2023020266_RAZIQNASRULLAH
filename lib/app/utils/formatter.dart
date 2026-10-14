import 'package:intl/intl.dart';

class Formatter {
  Formatter._();

  static final _rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  /// 12500 -> "Rp12.500"
  static String rupiah(num value) => _rupiah.format(value);

  /// Ringkas untuk sumbu grafik: 1500000 -> "1,5 jt"
  static String rupiahSingkat(num value) {
    if (value >= 1000000) {
      return '${NumberFormat('#,##0.#', 'id_ID').format(value / 1000000)} jt';
    }
    if (value >= 1000) {
      return '${NumberFormat('#,##0', 'id_ID').format(value / 1000)} rb';
    }
    return value.toStringAsFixed(0);
  }

  /// "14 Okt 2026, 10:12"
  static String tanggalJam(DateTime d) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d);

  /// "Rabu, 14 Oktober 2026"
  static String tanggalPanjang(DateTime d) =>
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(d);

  /// "14/10"
  static String tanggalPendek(DateTime d) => DateFormat('dd/MM').format(d);

  static String sapaan([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}
