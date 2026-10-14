import 'package:get/get.dart';

import '../data/services/keranjang_service.dart';
import '../models/keranjang_item.dart';
import '../models/pesanan.dart';
import '../models/produk.dart';
import '../utils/app_snackbar.dart';
import '../utils/biaya_calculator.dart';
import '../widgets/confirm_dialog.dart';

/// State keranjang global (permanent). Data disimpan di tabel `keranjang`.
class CartController extends GetxController {
  final KeranjangService _service = Get.find<KeranjangService>();

  final items = <KeranjangItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// Id item / produk yang sedang diproses (untuk indikator loading per item).
  final busyIds = <int>{}.obs;
  final addingProdukIds = <int>{}.obs;

  // ---- Nilai turunan reaktif (dibaca di dalam Obx) ----
  int get totalItem => items.fold(0, (sum, e) => sum + e.jumlah);
  double get subtotal => items.fold(0.0, (sum, e) => sum + e.subtotal);
  bool get isEmpty => items.isEmpty;
  RincianBiaya rincian(String metode) => RincianBiaya.hitung(subtotal, metode);
  RincianBiaya get estimasi => rincian(MetodePengambilan.ambil);

  /// Item yang jumlahnya melebihi stok terbaru.
  List<KeranjangItem> get itemMelebihiStok =>
      items.where((e) => e.jumlah > e.stok).toList();

  int jumlahDiKeranjang(int produkId) =>
      items.firstWhereOrNull((e) => e.produkId == produkId)?.jumlah ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart({bool showError = false}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _service.getAll();
      items.assignAll(res.items);
    } catch (e) {
      errorMessage.value = e.toString();
      if (showError) AppSnackbar.error(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart(Produk produk, {int jumlah = 1}) async {
    if (produk.stokHabis) {
      AppSnackbar.error('Stok ${produk.nama} habis.');
      return false;
    }
    final sudahAda = jumlahDiKeranjang(produk.id);
    if (sudahAda + jumlah > produk.stok) {
      AppSnackbar.error(
          'Jumlah melebihi stok. Stok tersisa ${produk.stok}, di keranjang sudah ada $sudahAda.');
      return false;
    }
    addingProdukIds.add(produk.id);
    try {
      final res = await _service.add(produk.id, jumlah: jumlah);
      items.assignAll(res.items);
      AppSnackbar.success(res.message, title: 'Ditambahkan');
      return true;
    } catch (e) {
      AppSnackbar.error(e);
      return false;
    } finally {
      addingProdukIds.remove(produk.id);
    }
  }

  /// Ubah jumlah dengan validasi: minimal 1 dan tidak melebihi stok.
  Future<void> changeQty(KeranjangItem item, int jumlah) async {
    if (jumlah < 1) {
      final hapus = await showConfirmDialog(
        title: 'Hapus item?',
        message: 'Jumlah minimal 1. Hapus ${item.nama} dari keranjang?',
        confirmLabel: 'Hapus',
      );
      if (hapus) await removeItem(item, confirm: false);
      return;
    }
    if (jumlah > item.stok) {
      AppSnackbar.error('Stok ${item.nama} hanya ${item.stok}.', title: 'Melebihi stok');
      return;
    }

    // Update optimistis agar subtotal & total langsung berubah.
    final index = items.indexWhere((e) => e.id == item.id);
    if (index < 0) return;
    final lama = items[index];
    items[index] = lama.copyWith(jumlah: jumlah);
    busyIds.add(item.id);
    try {
      final res = await _service.updateQty(item.id, jumlah);
      items.assignAll(res.items);
    } catch (e) {
      final i = items.indexWhere((x) => x.id == item.id);
      if (i >= 0) items[i] = lama;
      AppSnackbar.error(e);
    } finally {
      busyIds.remove(item.id);
    }
  }

  Future<void> removeItem(KeranjangItem item, {bool confirm = true}) async {
    if (confirm) {
      final ok = await showConfirmDialog(
        title: 'Hapus item?',
        message: 'Hapus ${item.nama} dari keranjang?',
        confirmLabel: 'Hapus',
      );
      if (!ok) return;
    }
    busyIds.add(item.id);
    try {
      final res = await _service.delete(item.id);
      items.assignAll(res.items);
      AppSnackbar.success(res.message);
    } catch (e) {
      AppSnackbar.error(e);
    } finally {
      busyIds.remove(item.id);
    }
  }

  Future<void> clearCart() async {
    final ok = await showConfirmDialog(
      title: 'Kosongkan keranjang?',
      message: 'Semua item di keranjang akan dihapus.',
      confirmLabel: 'Kosongkan',
    );
    if (!ok) return;
    isLoading.value = true;
    try {
      final res = await _service.clear();
      items.assignAll(res.items);
      AppSnackbar.success(res.message);
    } catch (e) {
      AppSnackbar.error(e);
    } finally {
      isLoading.value = false;
    }
  }
}
