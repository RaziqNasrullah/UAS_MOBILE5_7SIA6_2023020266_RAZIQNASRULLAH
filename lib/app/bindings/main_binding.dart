import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/katalog_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/pesanan_controller.dart';

/// Halaman utama berisi tab Beranda, Katalog, Keranjang, Riwayat, dan Admin.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
    Get.put(HomeController());
    Get.put(KatalogController());
    Get.lazyPut(() => PesananController(), fenix: true);
  }
}
