import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../controllers/struk_controller.dart';
import '../../theme/app_colors.dart';

/// Preview struk PDF (PdfPreview) + simpan ke perangkat + bagikan.
class StrukView extends GetView<StrukController> {
  const StrukView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Struk ${controller.pesanan.nomorPesanan}'),
        actions: [
          IconButton(
            tooltip: 'Bagikan',
            onPressed: controller.bagikan,
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => controller.buildPdf(),
        initialPageFormat: PdfPageFormat.a5,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowSharing: false,
        allowPrinting: true,
        pdfFileName: controller.fileName,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        onError: (_, e) => Center(child: Text('Gagal membuat PDF: $e')),
        pdfPreviewPageDecoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
        ),
        scrollViewDecoration: const BoxDecoration(color: AppColors.background),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => controller.savedPath.value == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Tersimpan: ${controller.savedPath.value}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    )),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.bagikan,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Bagikan'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                          onPressed: controller.isSaving.value ? null : controller.simpan,
                          icon: controller.isSaving.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.download_rounded),
                          label: const Text('Simpan PDF'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
