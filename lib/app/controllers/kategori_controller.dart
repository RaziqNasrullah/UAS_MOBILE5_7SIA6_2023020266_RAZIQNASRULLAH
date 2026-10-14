import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/kategori_service.dart';
import '../models/kategori.dart';
import '../routes/app_routes.dart';
import '../utils/app_refresh.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';

/// CRUD kategori: daftar, hapus, dan form tambah/ubah.
class KategoriController extends GetxController {
  final KategoriService _service = Get.find<KategoriService>();

  final kategori = <Kategori>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadKategori();
  }

  Future<void> loadKategori() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      kategori.assignAll(await _service.getAll());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bukaForm([Kategori? data]) async {
    final saved = await Get.toNamed(Routes.kategoriForm, arguments: data);
    if (saved == true) {
      await loadKategori();
      AppRefresh.katalog();
    }
  }

  Future<void> hapus(Kategori k) async {
    final ok = await showConfirmDialog(
      title: 'Hapus kategori?',
      message: 'Kategori "${k.nama}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
    );
    if (!ok) return;
    isLoading.value = true;
    try {
      final msg = await _service.delete(k.id);
      AppSnackbar.success(msg);
      await loadKategori();
      AppRefresh.katalog();
    } catch (e) {
      // Contoh: ditolak karena masih memiliki produk.
      AppSnackbar.error(e, title: 'Tidak dapat menghapus');
    } finally {
      isLoading.value = false;
    }
  }
}

class KategoriFormController extends GetxController {
  final KategoriService _service = Get.find<KategoriService>();

  final formKey = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();
  final isSaving = false.obs;

  Kategori? editing;
  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Kategori) {
      editing = arg;
      namaCtrl.text = arg.nama;
      deskripsiCtrl.text = arg.deskripsi ?? '';
    }
  }

  /// Nama kategori lain (untuk cek duplikat di sisi aplikasi).
  Iterable<String> get _namaLain {
    if (!Get.isRegistered<KategoriController>()) return const [];
    return Get.find<KategoriController>()
        .kategori
        .where((k) => k.id != editing?.id)
        .map((k) => k.nama);
  }

  String? validateNama(String? v) => Validators.namaKategori(v, _namaLain);

  Future<void> simpan() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.error('Periksa kembali isian form.', title: 'Form belum valid');
      return;
    }
    isSaving.value = true;
    try {
      final nama = namaCtrl.text.trim();
      final desk = deskripsiCtrl.text.trim();
      final msg = isEdit
          ? await _service.update(editing!.id, nama, desk)
          : await _service.create(nama, desk);
      Get.back(result: true);
      AppSnackbar.success(msg);
    } catch (e) {
      // Duplikat juga dicek di server (case-insensitive).
      AppSnackbar.error(e);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    deskripsiCtrl.dispose();
    super.onClose();
  }
}
