import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ChoiceChip kategori untuk filter (termasuk opsi "Semua").
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  /// Ikon default per nama ikon yang tersimpan di kolom kategori.ikon.
  static IconData iconFor(String? ikon) {
    switch (ikon) {
      case 'medication':
        return Icons.medication_rounded;
      case 'vitamin':
        return Icons.local_florist_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'spa':
        return Icons.spa_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      avatar: icon == null
          ? null
          : Icon(icon, size: 16, color: selected ? AppColors.onPrimary : AppColors.teal),
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        color: selected ? AppColors.onPrimary : AppColors.textDark,
      ),
    );
  }
}
