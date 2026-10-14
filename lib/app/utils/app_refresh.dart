import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/katalog_controller.dart';
import '../controllers/pesanan_controller.dart';

/// Menyegarkan halaman yang terdampak setelah data berubah
/// (CRUD produk/kategori, checkout, ubah status pesanan).
class AppRefresh {
  AppRefresh._();

  static void katalog() {
    if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadData();
    if (Get.isRegistered<KatalogController>()) {
      final c = Get.find<KatalogController>();
      c.loadKategori();
      c.loadProduk();
    }
    if (Get.isRegistered<CartController>()) Get.find<CartController>().loadCart();
  }

  static void pesanan() {
    if (Get.isRegistered<PesananController>()) {
      Get.find<PesananController>().loadPesanan();
    }
  }

  static void semua() {
    katalog();
    pesanan();
  }
}
