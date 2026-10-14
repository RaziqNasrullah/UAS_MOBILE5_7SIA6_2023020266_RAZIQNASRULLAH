import 'package:flutter/material.dart';

import '../models/produk.dart';
import '../theme/app_colors.dart';

/// Badge golongan obat, warnanya mengikuti penandaan resmi
/// (hijau = bebas, biru = bebas terbatas, merah = keras).
class GolonganBadge extends StatelessWidget {
  final String golongan;
  final bool compact;

  const GolonganBadge({super.key, required this.golongan, this.compact = false});

  IconData get _icon {
    switch (golongan) {
      case GolonganObat.herbal:
        return Icons.eco_rounded;
      case GolonganObat.nonObat:
        return Icons.health_and_safety_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.golongan(golongan);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 2 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 9 : 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              golongan,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 9.5 : 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
