import 'package:flutter/material.dart';

import '../models/pesanan.dart';
import '../models/produk.dart';

/// Palet warna MyHealthGw (diambil dari logo).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF8ADC64); // warna identitas utama
  static const primaryDark = Color(0xFF4FA83A);
  static const onPrimary = Color(0xFF113B2C);
  static const teal = Color(0xFF1C6E7D); // teks "MyHealth" pada logo
  static const tealLight = Color(0xFF3AAFA9);
  static const accent = Color(0xFFF5922F); // bintang oranye pada logo
  static const background = Color(0xFFF4F8F3);
  static const surface = Colors.white;
  static const textDark = Color(0xFF1D2A26);
  static const textMuted = Color(0xFF6B7A75);
  static const error = Color(0xFFD64545);
  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE6A23C);

  /// Warna badge golongan obat (mengikuti penandaan kemasan resmi).
  static Color golongan(String golongan) {
    switch (golongan) {
      case GolonganObat.bebas:
        return const Color(0xFF2E9E5B); // lingkaran hijau
      case GolonganObat.bebasTerbatas:
        return const Color(0xFF2F6FD6); // lingkaran biru
      case GolonganObat.keras:
        return const Color(0xFFD64545); // lingkaran merah huruf K
      case GolonganObat.herbal:
        return const Color(0xFF7A9A2E); // jamu / herbal
      default:
        return const Color(0xFF7D8A86); // non-obat
    }
  }

  static Color status(String status) {
    switch (status) {
      case StatusPesanan.selesai:
        return success;
      case StatusPesanan.dibatalkan:
        return error;
      default:
        return warning;
    }
  }
}
