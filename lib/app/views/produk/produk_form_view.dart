import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/produk_controller.dart';
import '../../models/produk.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/golongan_badge.dart';
import '../../widgets/product_image.dart';

class ProdukFormView extends GetView<ProdukFormController> {
  const ProdukFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.isEdit ? 'Ubah Produk' : 'Tambah Produk')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _gambarPicker(),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.namaCtrl,
              label: 'Nama produk *',
              icon: Icons.medication_rounded,
              maxLength: 150,
              validator: (v) => Validators.wajib(v, 'Nama produk'),
            ),
            // Dropdown kategori dari tabel kategori (FK)
            Obx(() => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DropdownButtonFormField<int>(
                    initialValue: controller.selectedKategoriId.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Kategori *',
                      prefixIcon: const Icon(Icons.category_rounded),
                      suffixIcon: controller.isLoadingKategori.value
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : (controller.kategoriError.value != null
                              ? IconButton(
                                  tooltip: 'Muat ulang kategori',
                                  onPressed: controller.loadKategori,
                                  icon: const Icon(Icons.refresh_rounded),
                                )
                              : null),
                    ),
                    items: controller.kategori
                        .map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama)))
                        .toList(),
                    onChanged: (v) => controller.selectedKategoriId.value = v,
                    validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                  ),
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: controller.hargaCtrl,
                    label: 'Harga *',
                    prefixText: 'Rp ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.harga,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: controller.stokCtrl,
                    label: 'Stok *',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.stok,
                  ),
                ),
              ],
            ),
            // Atribut khusus tema kesehatan: golongan obat
            Obx(() => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.golongan.value,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Golongan obat *',
                      prefixIcon: Icon(Icons.verified_user_rounded),
                    ),
                    items: GolonganObat.all
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GolonganBadge(golongan: g),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => controller.golongan.value = v,
                    validator: (v) => v == null ? 'Golongan obat wajib dipilih' : null,
                  ),
                )),
            CustomTextField(
              controller: controller.aturanPakaiCtrl,
              label: 'Aturan pakai / dosis *',
              hint: 'Contoh: Dewasa 3 x sehari 1 tablet sesudah makan',
              icon: Icons.medication_liquid_rounded,
              maxLines: 3,
              validator: (v) => Validators.wajib(v, 'Aturan pakai'),
            ),
            CustomTextField(
              controller: controller.deskripsiCtrl,
              label: 'Deskripsi *',
              icon: Icons.description_rounded,
              maxLines: 4,
              validator: (v) => Validators.wajib(v, 'Deskripsi'),
            ),
            Obx(() => Card(
                  child: SwitchListTile(
                    value: controller.isUnggulan.value,
                    onChanged: (v) => controller.isUnggulan.value = v,
                    title: const Text('Produk unggulan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Tampil di bagian unggulan Beranda'),
                    secondary: const Icon(Icons.star_rounded, color: AppColors.accent),
                  ),
                )),
            const SizedBox(height: 18),
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.isSaving.value ? null : controller.simpan,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_rounded),
                  label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan Produk'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _gambarPicker() {
    return Obx(() {
      final file = controller.pickedImage.value;
      final lama = controller.gambarLama.value;
      final adaGambar = file != null || lama != null;
      return Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: controller.pilihGambar,
            child: Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7E2DC)),
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(file, fit: BoxFit.cover),
                    )
                  : lama != null
                      ? ProductImage(gambar: lama, borderRadius: BorderRadius.circular(18))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded,
                                size: 48, color: AppColors.tealLight),
                            SizedBox(height: 6),
                            Text('Pilih gambar dari galeri',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('JPG / PNG / WEBP, maks. 2 MB',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
            ),
          ),
          if (adaGambar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: controller.pilihGambar,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Ganti'),
                ),
                TextButton.icon(
                  onPressed: controller.hapusGambar,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.hide_image_rounded),
                  label: const Text('Hapus gambar'),
                ),
              ],
            ),
        ],
      );
    });
  }
}
