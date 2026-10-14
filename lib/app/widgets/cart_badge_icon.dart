import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// Ikon keranjang dengan badge jumlah item (reaktif via Obx).
class CartBadgeIcon extends StatelessWidget {
  final bool asNavIcon;
  final bool selected;

  const CartBadgeIcon({super.key, this.asNavIcon = false, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final icon = Obx(() {
      final count = cart.totalItem;
      return Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        backgroundColor: AppColors.accent,
        textColor: Colors.white,
        child: Icon(selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined),
      );
    });
    if (asNavIcon) return icon;
    return IconButton(
      tooltip: 'Keranjang',
      onPressed: () => Get.toNamed(Routes.keranjang),
      icon: icon,
    );
  }
}
