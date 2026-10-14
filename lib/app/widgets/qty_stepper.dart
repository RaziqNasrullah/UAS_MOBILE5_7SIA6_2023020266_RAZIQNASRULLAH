import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tombol +/- jumlah dengan batas minimal & maksimal (stok).
class QtyStepper extends StatelessWidget {
  final int value;
  final int max;
  final int min;
  final ValueChanged<int> onChanged;
  final bool busy;

  const QtyStepper({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    this.min = 1,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD7E2DC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, busy ? null : () => onChanged(value - 1), value > min),
          SizedBox(
            width: 34,
            child: busy
                ? const Center(
                    child: SizedBox(
                        width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))
                : Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          // Tombol + tetap bisa ditekan agar pengguna mendapat pesan saat melebihi stok.
          _btn(Icons.add_rounded, busy ? null : () => onChanged(value + 1), value < max),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, bool active) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: active ? AppColors.teal : const Color(0xFFB9C4BF)),
        ),
      );
}
