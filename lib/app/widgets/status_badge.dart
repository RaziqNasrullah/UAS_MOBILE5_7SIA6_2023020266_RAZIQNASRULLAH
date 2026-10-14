import 'package:flutter/material.dart';

import '../models/pesanan.dart';
import '../theme/app_colors.dart';

/// Label status pesanan dengan warna berbeda per status.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(status);
    final icon = switch (status) {
      StatusPesanan.selesai => Icons.check_circle_rounded,
      StatusPesanan.dibatalkan => Icons.cancel_rounded,
      _ => Icons.timelapse_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
