import 'package:get/get.dart';

/// Mengatur tab bottom navigation pada halaman utama.
class MainController extends GetxController {
  static const tabBeranda = 0;
  static const tabKatalog = 1;
  static const tabKeranjang = 2;
  static const tabPesanan = 3;
  static const tabAdmin = 4;

  final tabIndex = 0.obs;

  void changeTab(int index) => tabIndex.value = index;
}
