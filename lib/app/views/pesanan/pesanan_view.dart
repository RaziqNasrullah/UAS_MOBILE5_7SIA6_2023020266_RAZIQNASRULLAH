import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

/// Riwayat pesanan, urut dari yang terbaru.
class PesananView extends GetView<PesananController> {
  const PesananView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  children: ['Semua', ...StatusPesanan.all]
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: s,
                              selected: controller.filterStatus.value == s,
                              onSelected: () => controller.filterStatus.value = s,
                            ),
                          ))
                      .toList(),
                )),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadPesanan,
              child: Obx(() {
                if (controller.isLoading.value && controller.pesanan.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value != null) {
                  return EmptyState.error(controller.errorMessage.value!, controller.loadPesanan);
                }
                if (controller.pesanan.isEmpty) {
                  return ListView(children: const [
                    SizedBox(height: 80),
                    EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum ada pesanan',
                      message: 'Pesanan yang kamu buat akan muncul di sini.',
                    ),
                  ]);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: controller.pesanan.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PesananTile(
                    pesanan: controller.pesanan[i],
                    onTap: () => controller.bukaDetail(controller.pesanan[i]),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PesananTile extends StatelessWidget {
  final Pesanan pesanan;
  final VoidCallback onTap;

  const _PesananTile({required this.pesanan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(pesanan.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 5))),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(pesanan.nomorPesanan,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.teal)),
                  ),
                  StatusBadge(status: pesanan.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(Formatter.tanggalJam(pesanan.tanggal),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    pesanan.metodePengambilan == MetodePengambilan.diantar
                        ? Icons.delivery_dining_rounded
                        : Icons.storefront_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${pesanan.namaPemesan} • ${pesanan.jumlahItem} item',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(Formatter.rupiah(pesanan.total),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
