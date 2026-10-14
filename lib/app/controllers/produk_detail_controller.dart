import 'package:get/get.dart';

import '../data/services/produk_service.dart';
import '../models/produk.dart';
import '../utils/app_snackbar.dart';
import 'cart_controller.dart';

/// Detail produk; objek Produk dikirim lewat `Get.arguments`.
class ProdukDetailController extends GetxController {
  final ProdukService _service = Get.find<ProdukService>();
  final CartController cart = Get.find<CartController>();

  late final Rx<Produk> produk;
  final qty = 1.obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is! Produk) {
      throw ArgumentError('ProdukDetailView membutuhkan argumen Produk');
    }
    produk = arg.obs;
    refreshProduk();
  }

  int get sisaBisaDitambah =>
      (produk.value.stok - cart.jumlahDiKeranjang(produk.value.id)).clamp(0, 9999);

  /// Ambil stok terbaru dari server.
  Future<void> refreshProduk() async {
    isRefreshing.value = true;
    try {
      produk.value = await _service.getDetail(produk.value.id);
      if (qty.value > sisaBisaDitambah) qty.value = sisaBisaDitambah.clamp(1, 9999);
    } catch (e) {
      AppSnackbar.error(e, title: 'Gagal memperbarui produk');
    } finally {
      isRefreshing.value = false;
    }
  }

  void setQty(int value) {
    if (value < 1) return;
    if (value > sisaBisaDitambah) {
      AppSnackbar.error('Maksimal $sisaBisaDitambah lagi (stok ${produk.value.stok}).',
          title: 'Melebihi stok');
      return;
    }
    qty.value = value;
  }

  Future<void> tambahKeKeranjang() async {
    final ok = await cart.addToCart(produk.value, jumlah: qty.value);
    if (ok) qty.value = 1;
  }
}
