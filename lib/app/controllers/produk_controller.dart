import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/services/kategori_service.dart';
import '../data/services/produk_service.dart';
import '../models/kategori.dart';
import '../models/produk.dart';
import '../routes/app_routes.dart';
import '../utils/app_refresh.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';

/// Kelola produk (admin): daftar dengan nama kategori hasil JOIN, hapus.
class ProdukController extends GetxController {
  final ProdukService _service = Get.find<ProdukService>();

  final produk = <Produk>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce<String>(searchQuery, (_) => loadProduk(),
        time: const Duration(milliseconds: 400));
    loadProduk();
  }

  Future<void> loadProduk() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      produk.assignAll(await _service.getAll(search: searchQuery.value));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bukaForm([Produk? data]) async {
    final saved = await Get.toNamed(Routes.produkForm, arguments: data);
    if (saved == true) {
      await loadProduk();
      AppRefresh.katalog();
    }
  }

  Future<void> hapus(Produk p) async {
    final ok = await showConfirmDialog(
      title: 'Hapus produk?',
      message:
          '"${p.nama}" akan dihapus. Riwayat pesanan tetap tersimpan karena nama & harga disalin saat checkout.',
      confirmLabel: 'Hapus',
    );
    if (!ok) return;
    isLoading.value = true;
    try {
      AppSnackbar.success(await _service.delete(p.id));
      await loadProduk();
      AppRefresh.katalog();
    } catch (e) {
      AppSnackbar.error(e);
    } finally {
      isLoading.value = false;
    }
  }
}

/// Form tambah / ubah produk termasuk upload gambar.
class ProdukFormController extends GetxController {
  final ProdukService _produkService = Get.find<ProdukService>();
  final KategoriService _kategoriService = Get.find<KategoriService>();
  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final hargaCtrl = TextEditingController();
  final stokCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();
  final aturanPakaiCtrl = TextEditingController();

  final kategori = <Kategori>[].obs;
  final selectedKategoriId = RxnInt();
  final golongan = RxnString();
  final isUnggulan = false.obs;
  final pickedImage = Rxn<File>();
  final gambarLama = RxnString();

  final isLoadingKategori = false.obs;
  final isSaving = false.obs;
  final kategoriError = RxnString();

  Produk? editing;
  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Produk) {
      editing = arg;
      namaCtrl.text = arg.nama;
      hargaCtrl.text = arg.harga.toStringAsFixed(0);
      stokCtrl.text = '${arg.stok}';
      deskripsiCtrl.text = arg.deskripsi;
      aturanPakaiCtrl.text = arg.aturanPakai;
      selectedKategoriId.value = arg.kategoriId;
      golongan.value = arg.golonganObat;
      isUnggulan.value = arg.isUnggulan;
      gambarLama.value = arg.gambar;
    }
    loadKategori();
  }

  Future<void> loadKategori() async {
    isLoadingKategori.value = true;
    kategoriError.value = null;
    try {
      kategori.assignAll(await _kategoriService.getAll());
      if (selectedKategoriId.value != null &&
          !kategori.any((k) => k.id == selectedKategoriId.value)) {
        selectedKategoriId.value = null;
      }
    } catch (e) {
      kategoriError.value = e.toString();
      AppSnackbar.error(e, title: 'Gagal memuat kategori');
    } finally {
      isLoadingKategori.value = false;
    }
  }

  Future<void> pilihGambar() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (file != null) pickedImage.value = File(file.path);
    } catch (e) {
      AppSnackbar.error('Tidak dapat membuka galeri: $e');
    }
  }

  void hapusGambar() {
    pickedImage.value = null;
    gambarLama.value = null;
  }

  Future<void> simpan() async {
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid || selectedKategoriId.value == null || golongan.value == null) {
      AppSnackbar.error('Lengkapi semua field yang wajib diisi.', title: 'Form belum valid');
      return;
    }
    isSaving.value = true;
    try {
      String? gambar = gambarLama.value;
      if (pickedImage.value != null) {
        gambar = await _produkService.uploadGambar(pickedImage.value!);
      }
      final data = Produk(
        id: editing?.id ?? 0,
        kategoriId: selectedKategoriId.value!,
        namaKategori: '',
        nama: namaCtrl.text.trim(),
        harga: Validators.parseHarga(hargaCtrl.text),
        stok: int.parse(stokCtrl.text.trim()),
        deskripsi: deskripsiCtrl.text.trim(),
        gambar: gambar,
        golonganObat: golongan.value!,
        aturanPakai: aturanPakaiCtrl.text.trim(),
        isUnggulan: isUnggulan.value,
      );
      final msg = isEdit
          ? await _produkService.update(data)
          : await _produkService.create(data);
      Get.back(result: true);
      AppSnackbar.success(msg);
    } catch (e) {
      AppSnackbar.error(e);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    hargaCtrl.dispose();
    stokCtrl.dispose();
    deskripsiCtrl.dispose();
    aturanPakaiCtrl.dispose();
    super.onClose();
  }
}
