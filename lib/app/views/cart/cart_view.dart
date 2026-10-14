import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/main_controller.dart';
import '../../models/keranjang_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/golongan_badge.dart';
import '../../widgets/product_image.dart';
import '../../widgets/qty_stepper.dart';

/// Keranjang belanja. Dipakai sebagai tab (standalone=false) dan route /keranjang.
class CartView extends GetView<CartController> {
  final bool standalone;

  const CartView({super.key, this.standalone = false});

  void _belanja() {
    if (standalone) Get.back();
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(MainController.tabKatalog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Keranjang (${controller.totalItem})')),
        actions: [
          Obx(() => controller.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Kosongkan keranjang',
                  onPressed: controller.clearCart,
                  icon: const Icon(Icons.delete_sweep_rounded),
                )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadCart(showError: true),
        child: Obx(() {
          if (controller.isLoading.value && controller.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null && controller.isEmpty) {
            return EmptyState.error(
                controller.errorMessage.value!, () => controller.loadCart(showError: true));
          }
          if (controller.isEmpty) {
            return ListView(children: [
              const SizedBox(height: 80),
              EmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Keranjang masih kosong',
                message: 'Yuk, cari obat & vitamin yang kamu butuhkan.',
                actionLabel: 'Mulai Belanja',
                onAction: _belanja,
              ),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CartTile(item: controller.items[i]),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isEmpty) return const SizedBox.shrink();
        final r = controller.estimasi;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE3ECE6))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!r.dapatDiskon)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_rounded, size: 16, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Belanja ${Formatter.rupiah(r.kurangUntukDiskon)} lagi untuk diskon 10%',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total (${controller.totalItem} item)',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text(
                            Formatter.rupiah(controller.subtotal),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(Routes.checkout),
                        icon: const Icon(Icons.payment_rounded),
                        label: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _CartTile extends StatelessWidget {
  final KeranjangItem item;

  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();
    final lebih = item.jumlah > item.stok;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(gambar: item.gambar, width: 76, height: 76),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(item.nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      InkWell(
                        onTap: () => c.removeItem(item),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GolonganBadge(golongan: item.golonganObat, compact: true),
                  const SizedBox(height: 4),
                  Text('${Formatter.rupiah(item.harga)} • Stok ${item.stok}',
                      style: TextStyle(
                          fontSize: 12, color: lebih ? AppColors.error : AppColors.textMuted)),
                  if (lebih)
                    const Text('Jumlah melebihi stok, kurangi jumlah.',
                        style: TextStyle(fontSize: 11, color: AppColors.error)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Obx(() => QtyStepper(
                            value: item.jumlah,
                            max: item.stok,
                            busy: c.busyIds.contains(item.id),
                            onChanged: (v) => c.changeQty(item, v),
                          )),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Text(Formatter.rupiah(item.subtotal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, color: AppColors.teal)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
