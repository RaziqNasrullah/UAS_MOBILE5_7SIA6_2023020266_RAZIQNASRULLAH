import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../widgets/cart_badge_icon.dart';
import '../admin/admin_view.dart';
import '../cart/cart_view.dart';
import '../home/home_view.dart';
import '../katalog/katalog_view.dart';
import '../pesanan/pesanan_view.dart';

/// Kerangka utama dengan bottom navigation.
class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const _pages = [
    HomeView(),
    KatalogView(),
    CartView(),
    PesananView(),
    AdminView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.tabIndex.value;
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.changeTab(0);
        },
        child: Scaffold(
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: controller.changeTab,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Katalog',
              ),
              NavigationDestination(
                icon: const CartBadgeIcon(asNavIcon: true),
                selectedIcon: const CartBadgeIcon(asNavIcon: true, selected: true),
                label: 'Keranjang',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Riwayat',
              ),
              const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Admin',
              ),
            ],
          ),
        ),
      );
    });
  }
}
