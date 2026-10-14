import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';

/// Kartu rincian biaya (dipakai di checkout, sukses, dan detail pesanan).
class RincianBiayaCard extends StatelessWidget {
  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;
  final double total;
  final int jumlahItem;

  const RincianBiayaCard({
    super.key,
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
    required this.total,
    required this.jumlahItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _row('Subtotal ($jumlahItem item)', Formatter.rupiah(subtotal)),
            _row('Biaya layanan', Formatter.rupiah(biayaLayanan)),
            _row('Ongkos kirim', Formatter.rupiah(ongkir)),
            _row('Diskon', '- ${Formatter.rupiah(diskon)}',
                color: diskon > 0 ? AppColors.success : null),
            const Divider(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text('Total Bayar',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                Text(Formatter.rupiah(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.teal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );
}
