import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../checkout/rincian_biaya_card.dart';

class PesananDetailView extends GetView<PesananDetailController> {
  const PesananDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          Obx(() => controller.pesanan.value == null
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Cetak struk',
                  onPressed: controller.cetakStruk,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(() {
          final p = controller.pesanan.value;
          if (controller.isLoading.value && p == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null && p == null) {
            return EmptyState.error(controller.errorMessage.value!, controller.load);
          }
          if (p == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.nomorPesanan,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.teal)),
                          ),
                          StatusBadge(status: p.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(Formatter.tanggalJam(p.tanggal),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      const Divider(height: 22),
                      _info(Icons.person_rounded, 'Pemesan', p.namaPemesan),
                      _info(Icons.phone_rounded, 'No. HP', p.noHp),
                      _info(Icons.local_shipping_rounded, 'Pengambilan', p.metodePengambilan),
                      if (p.alamat != null) _info(Icons.location_on_rounded, 'Alamat', p.alamat!),
                      if (p.catatan != null) _info(Icons.edit_note_rounded, 'Catatan', p.catatan!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Item Pesanan (${p.items.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < p.items.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14),
                      ListTile(
                        title: Text(p.items[i].namaProduk,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${p.items[i].jumlah} x ${Formatter.rupiah(p.items[i].hargaSatuan)}'),
                        trailing: Text(Formatter.rupiah(p.items[i].subtotal),
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RincianBiayaCard(
                subtotal: p.subtotal,
                biayaLayanan: p.biayaLayanan,
                ongkir: p.ongkir,
                diskon: p.diskon,
                total: p.total,
                jumlahItem: p.jumlahItem,
              ),
              const SizedBox(height: 18),
              if (p.bisaDiubah) ...[
                Text('Ubah Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        onPressed: controller.isUpdating.value
                            ? null
                            : () => controller.ubahStatus(StatusPesanan.dibatalkan),
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text('Batalkan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isUpdating.value
                            ? null
                            : () => controller.ubahStatus(StatusPesanan.selesai),
                        icon: controller.isUpdating.value
                            ? const SizedBox(
                                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check_circle_rounded),
                        label: const Text('Selesai'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Membatalkan pesanan akan mengembalikan stok produk.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: controller.cetakStruk,
                icon: const Icon(Icons.print_rounded),
                label: const Text('Cetak Struk PDF'),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.teal),
            const SizedBox(width: 8),
            SizedBox(
                width: 90,
                child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
