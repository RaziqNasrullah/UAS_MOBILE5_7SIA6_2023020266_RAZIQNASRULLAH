import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../models/pesanan.dart';
import '../utils/app_snackbar.dart';
import '../utils/pdf_generator.dart';

/// Preview, simpan, dan bagikan struk PDF. Data pesanan dari `Get.arguments`.
class StrukController extends GetxController {
  late final Pesanan pesanan;
  final isSaving = false.obs;
  final savedPath = RxnString();

  Uint8List? _cache;

  @override
  void onInit() {
    super.onInit();
    pesanan = Get.arguments as Pesanan;
  }

  String get fileName => PdfGenerator.namaFile(pesanan);

  Future<Uint8List> buildPdf() async =>
      _cache ??= await PdfGenerator.buildStruk(pesanan);

  Future<void> simpan() async {
    isSaving.value = true;
    try {
      final path = await PdfGenerator.simpanKePerangkat(await buildPdf(), fileName);
      savedPath.value = path;
      AppSnackbar.success('Struk disimpan di:\n$path', title: 'PDF tersimpan');
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan PDF: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> bagikan() async {
    try {
      await Printing.sharePdf(bytes: await buildPdf(), filename: fileName);
    } catch (e) {
      AppSnackbar.error('Gagal membagikan PDF: $e');
    }
  }
}
