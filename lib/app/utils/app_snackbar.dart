import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Pembungkus Get.snackbar agar tampilan pesan sukses/error seragam.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'Berhasil'}) =>
      _show(title, message, AppColors.success, Icons.check_circle_rounded);

  static void error(Object message, {String title = 'Gagal'}) =>
      _show(title, message.toString(), AppColors.error, Icons.error_rounded);

  static void info(String message, {String title = 'Info'}) =>
      _show(title, message, AppColors.teal, Icons.info_rounded);

  static void _show(String title, String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }
}
