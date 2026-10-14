import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/produk_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/golongan_badge.dart';
import '../../widgets/product_image.dart';

/// Daftar produk admin (nama kategori dari query JOIN).
class ProdukView extends GetView<ProdukController> {
  const ProdukView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.bukaForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Produk'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v.trim(),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Obx(() => controller.isLoading.value
              ? const LinearProgressIndicator()
              : const SizedBox(height: 4)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadProduk,
              child: Obx(() {
                if (controller.isLoading.value && controller.produk.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value != null) {
                  return EmptyState.error(controller.errorMessage.value!, controller.loadProduk);
                }
                if (controller.produk.isEmpty) {
                  return ListView(children: const [
                    SizedBox(height: 60),
                    EmptyState(icon: Icons.inventory_2_outlined, title: 'Tidak ada produk'),
                  ]);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: controller.produk.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = controller.produk[i];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => controller.bukaForm(p),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ProductImage(gambar: p.gambar, width: 64, height: 64),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nama,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(p.namaKategori,
                                        style: const TextStyle(fontSize: 12, color: AppColors.teal)),
                                    const SizedBox(height: 4),
                                    GolonganBadge(golongan: p.golonganObat, compact: true),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${Formatter.rupiah(p.harga)} • Stok ${p.stok}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: p.stokHabis ? AppColors.error : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    tooltip: 'Ubah',
                                    onPressed: () => controller.bukaForm(p),
                                    icon: const Icon(Icons.edit_rounded, color: AppColors.teal),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    onPressed: () => controller.hapus(p),
                                    icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
