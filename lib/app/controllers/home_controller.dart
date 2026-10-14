import 'package:get/get.dart';

import '../data/services/kategori_service.dart';
import '../data/services/produk_service.dart';
import '../models/kategori.dart';
import '../models/produk.dart';
import 'katalog_controller.dart';
import 'main_controller.dart';

class HomeController extends GetxController {
  final KategoriService _kategoriService = Get.find<KategoriService>();
  final ProdukService _produkService = Get.find<ProdukService>();

  final kategori = <Kategori>[].obs;
  final unggulan = <Produk>[].obs;
  final terbaru = <Produk>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _kategoriService.getAll(),
        _produkService.getAll(unggulan: true, limit: 10),
        _produkService.getAll(terbaru: true, limit: 6),
      ]);
      kategori.assignAll(results[0] as List<Kategori>);
      unggulan.assignAll(results[1] as List<Produk>);
      terbaru.assignAll(results[2] as List<Produk>);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Dari chip kategori di beranda -> buka tab katalog dengan filter kategori.
  void bukaKatalog({int? kategoriId, bool fokusCari = false}) {
    if (Get.isRegistered<KatalogController>()) {
      final katalog = Get.find<KatalogController>();
      katalog.pilihKategori(kategoriId ?? 0);
      if (fokusCari) katalog.requestSearchFocus();
    }
    Get.find<MainController>().changeTab(MainController.tabKatalog);
  }
}
