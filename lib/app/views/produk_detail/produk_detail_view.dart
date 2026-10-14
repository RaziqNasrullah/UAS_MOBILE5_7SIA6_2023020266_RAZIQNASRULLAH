import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/produk_detail_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/golongan_badge.dart';
import '../../widgets/product_image.dart';
import '../../widgets/qty_stepper.dart';

class ProdukDetailView extends GetView<ProdukDetailController> {
  const ProdukDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: const [CartBadgeIcon(), SizedBox(width: 6)],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshProduk,
        child: Obx(() {
          final p = controller.produk.value;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Hero(
                tag: 'produk-${p.id}',
                child: ProductImage(
                  gambar: p.gambar,
                  height: 280,
                  width: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        GolonganBadge(golongan: p.golonganObat),
                        _chip(Icons.category_rounded, p.namaKategori),
                        if (p.isUnggulan) _chip(Icons.star_rounded, 'Unggulan', AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(p.nama, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      Formatter.rupiah(p.harga),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.teal),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          p.stokHabis ? Icons.remove_shopping_cart_rounded : Icons.inventory_2_rounded,
                          size: 18,
                          color: p.stokHabis ? AppColors.error : AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.stokHabis ? 'Stok habis' : 'Stok tersedia: ${p.stok}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: p.stokHabis ? AppColors.error : AppColors.success,
                          ),
                        ),
                        const Spacer(),
                        if (controller.isRefreshing.value)
                          const SizedBox(
                              width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    Obx(() {
                      final diKeranjang = controller.cart.jumlahDiKeranjang(p.id);
                      if (diKeranjang == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('$diKeranjang sudah ada di keranjang',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      );
                    }),
                    const SizedBox(height: 18),
                    _section(
                      context,
                      icon: Icons.medication_liquid_rounded,
                      title: 'Aturan Pakai / Dosis',
                      body: p.aturanPakai,
                      highlight: true,
                    ),
                    const SizedBox(height: 12),
                    _section(
                      context,
                      icon: Icons.description_rounded,
                      title: 'Deskripsi',
                      body: p.deskripsi,
                    ),
                    if (p.golonganObat != 'Non-Obat') ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Baca aturan pakai sebelum digunakan. Bila sakit berlanjut, hubungi dokter.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE3ECE6))),
          ),
          child: Obx(() {
            final p = controller.produk.value;
            final adding = controller.cart.addingProdukIds.contains(p.id);
            final sisa = controller.sisaBisaDitambah;
            final bisa = !p.stokHabis && sisa > 0;
            return Row(
              children: [
                if (bisa) ...[
                  QtyStepper(
                    value: controller.qty.value,
                    max: sisa,
                    onChanged: controller.setQty,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    // Nonaktif jika stok 0 atau semua stok sudah di keranjang.
                    onPressed: (!bisa || adding) ? null : controller.tambahKeKeranjang,
                    icon: adding
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_shopping_cart_rounded),
                    label: Text(p.stokHabis
                        ? 'Stok Habis'
                        : (sisa <= 0 ? 'Stok sudah di keranjang' : 'Tambah ke Keranjang')),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, [Color color = AppColors.teal]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _section(BuildContext context,
      {required IconData icon, required String title, required String body, bool highlight = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFEFF9EA) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: highlight ? const Color(0xFFC8EBB6) : const Color(0xFFE3ECE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.teal),
              const SizedBox(width: 6),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}
