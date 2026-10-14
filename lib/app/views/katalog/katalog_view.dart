import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';

/// Katalog produk: GridView + pencarian realtime + filter ChoiceChip kategori.
class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: const [CartBadgeIcon(), SizedBox(width: 6)],
      ),
      body: Column(
        children: [
          // ---- Pencarian realtime ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Obx(() => TextField(
                  controller: controller.searchCtrl,
                  focusNode: controller.searchFocus,
                  onChanged: controller.onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: controller.searchQuery.value.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: controller.clearSearch,
                          ),
                  ),
                )),
          ),
          // ---- Filter kategori (ChoiceChip) ----
          SizedBox(
            height: 52,
            child: Obx(() {
              final selected = controller.selectedKategoriId.value;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  CategoryChip(
                    label: 'Semua',
                    icon: Icons.apps_rounded,
                    selected: selected == 0,
                    onSelected: () => controller.pilihKategori(0),
                  ),
                  for (final k in controller.kategori) ...[
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: k.nama,
                      icon: CategoryChip.iconFor(k.ikon),
                      selected: selected == k.id,
                      onSelected: () => controller.pilihKategori(k.id),
                    ),
                  ],
                ],
              );
            }),
          ),
          Obx(() {
            final q = controller.searchQuery.value;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${controller.produk.length} produk'
                      '${q.isEmpty ? '' : ' untuk "$q"'}'
                      ' • ${controller.namaFilter}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                  if (controller.isLoading.value)
                    const SizedBox(
                        width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            );
          }),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshAll,
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
                    EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Produk tidak ditemukan',
                      message: 'Coba kata kunci lain atau pilih kategori "Semua".',
                    ),
                  ]);
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: controller.produk.length,
                  itemBuilder: (_, i) {
                    final p = controller.produk[i];
                    return ProductCard(
                      produk: p,
                      onTap: () => Get.toNamed(Routes.produkDetail, arguments: p),
                      onAddToCart: () => cart.addToCart(p),
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
