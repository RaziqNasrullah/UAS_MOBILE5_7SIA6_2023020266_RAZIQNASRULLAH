import 'package:flutter/material.dart';

import '../models/produk.dart';
import '../theme/app_colors.dart';
import '../utils/formatter.dart';
import 'golongan_badge.dart';
import 'product_image.dart';

/// Kartu produk untuk GridView katalog & daftar unggulan.
class ProductCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.produk,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final habis = produk.stokHabis;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'produk-${produk.id}',
                      child: ProductImage(
                        gambar: produk.gambar,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  if (produk.isUnggulan)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: _Tag(text: 'Unggulan', color: AppColors.accent, icon: Icons.star_rounded),
                    ),
                  if (habis)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.65),
                        alignment: Alignment.center,
                        child: const _Tag(text: 'Stok Habis', color: AppColors.error),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GolonganBadge(golongan: produk.golonganObat, compact: true),
                  const SizedBox(height: 5),
                  Text(
                    produk.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.25),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    produk.namaKategori,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatter.rupiah(produk.harga),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.teal,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Stok ${produk.stok}',
                              style: TextStyle(
                                fontSize: 11,
                                color: habis ? AppColors.error : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onAddToCart != null)
                        Material(
                          color: habis ? const Color(0xFFDADFDC) : AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: habis ? null : onAddToCart,
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(Icons.add_shopping_cart_rounded,
                                  size: 18, color: AppColors.onPrimary),
                            ),
                          ),
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

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Tag({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 12, color: Colors.white),
          if (icon != null) const SizedBox(width: 2),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
