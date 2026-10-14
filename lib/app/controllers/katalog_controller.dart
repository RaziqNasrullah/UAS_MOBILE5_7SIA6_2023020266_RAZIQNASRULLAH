import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/kategori_service.dart';
import '../data/services/produk_service.dart';
import '../models/kategori.dart';
import '../models/produk.dart';

/// Katalog dengan pencarian realtime (debounce 400 ms) + filter kategori.
class KatalogController extends GetxController {
  final KategoriService _kategoriService = Get.find<KategoriService>();
  final ProdukService _produkService = Get.find<ProdukService>();

  final searchCtrl = TextEditingController();
  final searchFocus = FocusNode();

  final searchQuery = ''.obs;
  final selectedKategoriId = 0.obs; // 0 = Semua
  final kategori = <Kategori>[].obs;
  final produk = <Produk>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  int _requestId = 0;

  String get namaFilter => selectedKategoriId.value == 0
      ? 'Semua'
      : kategori.firstWhereOrNull((k) => k.id == selectedKategoriId.value)?.nama ?? '-';

  @override
  void onInit() {
    super.onInit();
    // Pencarian realtime: request dikirim 400 ms setelah pengguna berhenti mengetik.
    debounce<String>(searchQuery, (_) => loadProduk(),
        time: const Duration(milliseconds: 400));
    // Filter kategori langsung memuat ulang (kombinasi dengan kata kunci).
    ever<int>(selectedKategoriId, (_) => loadProduk());
    loadKategori();
    loadProduk();
  }

  void onSearchChanged(String value) => searchQuery.value = value.trim();

  void clearSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
  }

  void pilihKategori(int id) {
    if (selectedKategoriId.value == id) {
      loadProduk();
    } else {
      selectedKategoriId.value = id;
    }
  }

  void requestSearchFocus() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (searchFocus.canRequestFocus) searchFocus.requestFocus();
    });
  }

  Future<void> loadKategori() async {
    try {
      kategori.assignAll(await _kategoriService.getAll());
    } catch (_) {
      // Error utama ditampilkan oleh loadProduk.
    }
  }

  Future<void> loadProduk() async {
    final id = ++_requestId;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _produkService.getAll(
        search: searchQuery.value,
        kategoriId: selectedKategoriId.value == 0 ? null : selectedKategoriId.value,
      );
      if (id != _requestId) return; // abaikan respons lama
      produk.assignAll(data);
    } catch (e) {
      if (id != _requestId) return;
      errorMessage.value = e.toString();
    } finally {
      if (id == _requestId) isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadKategori(), loadProduk()]);
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
