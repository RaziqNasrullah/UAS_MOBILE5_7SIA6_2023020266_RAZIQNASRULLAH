import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kategori_controller.dart';
import '../../widgets/custom_text_field.dart';

class KategoriFormView extends GetView<KategoriFormController> {
  const KategoriFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.isEdit ? 'Ubah Kategori' : 'Tambah Kategori')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: controller.namaCtrl,
              label: 'Nama kategori *',
              icon: Icons.category_rounded,
              maxLength: 100,
              validator: controller.validateNama,
            ),
            CustomTextField(
              controller: controller.deskripsiCtrl,
              label: 'Deskripsi (opsional)',
              icon: Icons.notes_rounded,
              maxLines: 3,
              maxLength: 255,
            ),
            const SizedBox(height: 8),
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.isSaving.value ? null : controller.simpan,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_rounded),
                  label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan'),
                )),
          ],
        ),
      ),
    );
  }
}
