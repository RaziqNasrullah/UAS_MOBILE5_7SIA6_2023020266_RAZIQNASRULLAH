import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/pesanan_service.dart';
import '../models/pesanan.dart';
import '../routes/app_routes.dart';
import '../utils/app_refresh.dart';
import '../utils/app_snackbar.dart';
import '../utils/biaya_calculator.dart';
import 'cart_controller.dart';

class CheckoutController extends GetxController {
  final PesananService _service = Get.find<PesananService>();
  final CartController cart = Get.find<CartController>();

  final formKey = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final noHpCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  final catatanCtrl = TextEditingController();

  final metode = MetodePengambilan.ambil.obs;
  final isSubmitting = false.obs;

  bool get isDiantar => metode.value == MetodePengambilan.diantar;

  /// Rincian biaya reaktif (berubah saat metode / keranjang berubah).
  RincianBiaya get rincian => cart.rincian(metode.value);

  String? validateAlamat(String? v) {
    if (!isDiantar) return null;
    return (v == null || v.trim().isEmpty)
        ? 'Alamat wajib diisi untuk metode Diantar'
        : null;
  }

  Future<void> submit() async {
    if (cart.isEmpty) {
      AppSnackbar.error('Keranjang masih kosong.');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.error('Periksa kembali data pemesan.', title: 'Form belum valid');
      return;
    }
    final lebih = cart.itemMelebihiStok;
    if (lebih.isNotEmpty) {
      AppSnackbar.error(
          'Stok tidak mencukupi untuk: ${lebih.map((e) => '${e.nama} (stok ${e.stok})').join(', ')}',
          title: 'Stok tidak cukup');
      return;
    }

    isSubmitting.value = true;
    try {
      final pesanan = await _service.checkout(
        namaPemesan: namaCtrl.text.trim(),
        noHp: noHpCtrl.text.replaceAll(RegExp(r'[\s-]'), ''),
        metodePengambilan: metode.value,
        alamat: isDiantar ? alamatCtrl.text.trim() : null,
        catatan: catatanCtrl.text.trim(),
      );
      // Server sudah mengurangi stok & mengosongkan keranjang dalam satu transaksi.
      await cart.loadCart();
      AppRefresh.semua();
      AppSnackbar.success('Pesanan ${pesanan.nomorPesanan} berhasil dibuat.');
      Get.offNamed(Routes.checkoutSukses, arguments: pesanan);
    } catch (e) {
      AppSnackbar.error(e, title: 'Checkout gagal');
      await cart.loadCart(); // sinkronkan stok terbaru
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    noHpCtrl.dispose();
    alamatCtrl.dispose();
    catatanCtrl.dispose();
    super.onClose();
  }
}
