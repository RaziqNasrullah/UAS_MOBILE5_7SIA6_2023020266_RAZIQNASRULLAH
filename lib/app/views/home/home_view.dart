import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/home_controller.dart';
import '../../data/services/api_config.dart';
import '../../models/produk.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logo/logo_icon.png', width: 34, height: 34),
            const SizedBox(width: 8),
            const Text(ApiConfig.namaAplikasi),
          ],
        ),
        actions: const [CartBadgeIcon(), SizedBox(width: 6)],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadData();
          await cart.loadCart();
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.kategori.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null && controller.kategori.isEmpty) {
            return ListView(children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: EmptyState.error(controller.errorMessage.value!, controller.loadData),
              ),
            ]);
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _banner(context),
              _searchShortcut(),
              const SectionHeader(title: 'Kategori'),
              _kategoriList(),
              SectionHeader(
                title: 'Produk Unggulan',
                actionLabel: 'Lihat semua',
                onAction: () => controller.bukaKatalog(),
              ),
              _produkHorizontal(controller.unggulan, cart),
              const SectionHeader(title: 'Produk Terbaru'),
              _produkHorizontal(controller.terbaru, cart),
            ],
          );
        }),
      ),
    );
  }

  Widget _banner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.teal, AppColors.tealLight, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${Formatter.sapaan()} 👋',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                const Text(
                  'Selamat datang di\n${ApiConfig.namaToko}',
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Diskon ${ApiConfig.persenDiskon.toInt()}% belanja min. ${Formatter.rupiah(ApiConfig.minSubtotalDiskon)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Image.asset('assets/logo/logo_icon.png', width: 72, height: 72),
          ),
        ],
      ),
    );
  }

  Widget _searchShortcut() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => controller.bukaKatalog(fokusCari: true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD7E2DC)),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.teal),
              SizedBox(width: 10),
              Text('Cari obat, vitamin, alat kesehatan...',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kategoriList() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: controller.kategori.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final k = controller.kategori[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => controller.bukaKatalog(kategoriId: k.id),
            child: Container(
              width: 104,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE3ECE6)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDF5D0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CategoryChip.iconFor(k.ikon), color: AppColors.teal, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    k.nama,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.15),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _produkHorizontal(List<Produk> list, CartController cart) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text('Belum ada produk.', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return SizedBox(
      height: 290,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = list[i];
          return SizedBox(
            width: 170,
            child: ProductCard(
              produk: p,
              onTap: () => Get.toNamed(Routes.produkDetail, arguments: p),
              onAddToCart: () => cart.addToCart(p),
            ),
          );
        },
      ),
    );
  }
}
