import 'dart:ui' show Color;

import 'package:get/get.dart';

import '../data/services/pesanan_service.dart';
import '../models/pesanan.dart';
import '../routes/app_routes.dart';
import '../utils/app_refresh.dart';
import '../utils/app_snackbar.dart';
import '../widgets/confirm_dialog.dart';

/// Riwayat pesanan (urut terbaru) dengan filter status.
class PesananController extends GetxController {
  final PesananService _service = Get.find<PesananService>();

  final pesanan = <Pesanan>[].obs;
  final filterStatus = 'Semua'.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever<String>(filterStatus, (_) => loadPesanan());
    loadPesanan();
  }

  Future<void> loadPesanan() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      pesanan.assignAll(await _service.getAll(
          status: filterStatus.value == 'Semua' ? null : filterStatus.value));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void bukaDetail(Pesanan p) => Get.toNamed(Routes.pesananDetail, arguments: p.id);
}

/// Detail pesanan; id pesanan dikirim lewat `Get.arguments`.
class PesananDetailController extends GetxController {
  final PesananService _service = Get.find<PesananService>();

  late final int pesananId;
  final pesanan = Rxn<Pesanan>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    pesananId = arg is Pesanan ? arg.id : (arg as int);
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      pesanan.value = await _service.getDetail(pesananId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ubahStatus(String status) async {
    final p = pesanan.value;
    if (p == null) return;
    final batal = status == StatusPesanan.dibatalkan;
    final ok = await showConfirmDialog(
      title: batal ? 'Batalkan pesanan?' : 'Tandai selesai?',
      message: batal
          ? 'Pesanan ${p.nomorPesanan} akan dibatalkan dan stok produk dikembalikan.'
          : 'Pesanan ${p.nomorPesanan} akan ditandai selesai dan dihitung sebagai pendapatan.',
      confirmLabel: batal ? 'Batalkan' : 'Selesai',
      confirmColor: batal ? const Color(0xFFD64545) : const Color(0xFF2E9E5B),
    );
    if (!ok) return;

    isUpdating.value = true;
    try {
      final (updated, msg) = await _service.updateStatus(p.id, status);
      pesanan.value = updated;
      AppSnackbar.success(msg);
      AppRefresh.semua();
    } catch (e) {
      AppSnackbar.error(e);
    } finally {
      isUpdating.value = false;
    }
  }

  void cetakStruk() {
    final p = pesanan.value;
    if (p != null) Get.toNamed(Routes.struk, arguments: p);
  }
}
