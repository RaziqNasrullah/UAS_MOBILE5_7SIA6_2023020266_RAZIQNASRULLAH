import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/services/api_config.dart';
import '../theme/app_colors.dart';

/// Gambar produk dari server dengan placeholder & fallback saat gagal dimuat.
class ProductImage extends StatelessWidget {
  final String? gambar;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.gambar,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.imageUrl(gambar);
    final fallback = Container(
      width: width,
      height: height,
      color: const Color(0xFFEAF6E4),
      alignment: Alignment.center,
      child: const Icon(Icons.medication_rounded, color: AppColors.tealLight, size: 36),
    );
    return ClipRRect(
      borderRadius: borderRadius,
      child: url == null
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, _) => Container(
                width: width,
                height: height,
                color: const Color(0xFFF0F5F2),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
