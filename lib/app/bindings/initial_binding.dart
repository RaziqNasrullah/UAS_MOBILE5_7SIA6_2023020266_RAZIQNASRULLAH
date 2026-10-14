import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../data/services/api_service.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/keranjang_service.dart';
import '../data/services/pesanan_service.dart';
import '../data/services/produk_service.dart';

/// Dependency global yang hidup sepanjang aplikasi.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(KategoriService(), permanent: true);
    Get.put(ProdukService(), permanent: true);
    Get.put(KeranjangService(), permanent: true);
    Get.put(PesananService(), permanent: true);
    Get.put(DashboardService(), permanent: true);
    Get.put(CartController(), permanent: true);
  }
}
