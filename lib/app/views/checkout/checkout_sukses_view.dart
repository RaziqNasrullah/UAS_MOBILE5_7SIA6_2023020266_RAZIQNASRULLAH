import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../models/pesanan.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import 'rincian_biaya_card.dart';

/// Halaman sukses checkout; data pesanan diterima lewat `Get.arguments`.
class CheckoutSuksesView extends StatelessWidget {
  const CheckoutSuksesView({super.key});

  void _keBeranda() {
    Get.until((route) => route.settings.name == Routes.main);
    if (Get.isRegistered<MainController>()) Get.find<MainController>().changeTab(0);
  }

  @override
  Widget build(BuildContext context) {
    final p = Get.arguments as Pesanan;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _keBeranda();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Berhasil'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFDDF5D0),
              child: Icon(Icons.check_rounded, size: 56, color: AppColors.success),
            ),
            const SizedBox(height: 14),
            const Text('Terima kasih!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.teal)),
            const SizedBox(height: 4),
            const Text('Pesanan kamu sedang diproses.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _row('No. Pesanan', p.nomorPesanan, bold: true),
                    _row('Tanggal', Formatter.tanggalJam(p.tanggal)),
                    _row('Pemesan', p.namaPemesan),
                    _row('No. HP', p.noHp),
                    _row('Pengambilan', p.metodePengambilan),
                    if (p.alamat != null) _row('Alamat', p.alamat!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            RincianBiayaCard(
              subtotal: p.subtotal,
              biayaLayanan: p.biayaLayanan,
              ongkir: p.ongkir,
              diskon: p.diskon,
              total: p.total,
              jumlahItem: p.jumlahItem,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.struk, arguments: p),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Lihat & Simpan Struk PDF'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed(Routes.pesananDetail, arguments: p.id),
              icon: const Icon(Icons.receipt_long_rounded),
              label: const Text('Lihat Detail Pesanan'),
            ),
            const SizedBox(height: 4),
            TextButton(onPressed: _keBeranda, child: const Text('Kembali ke Beranda')),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 100,
                child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
                      color: bold ? AppColors.teal : null)),
            ),
          ],
        ),
      );
}
