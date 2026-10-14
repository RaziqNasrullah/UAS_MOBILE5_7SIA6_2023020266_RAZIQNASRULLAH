import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kartu ringkasan angka untuk dashboard.
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? caption;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppColors.teal,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(caption!,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
