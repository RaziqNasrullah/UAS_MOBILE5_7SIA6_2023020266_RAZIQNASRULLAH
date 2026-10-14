import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Dialog konfirmasi sederhana. Mengembalikan true jika pengguna setuju.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  Color confirmColor = AppColors.error,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Get.back(result: true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
