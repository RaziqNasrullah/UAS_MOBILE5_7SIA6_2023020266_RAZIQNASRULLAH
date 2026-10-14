import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kategori_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';

class KategoriView extends GetView<KategoriController> {
  const KategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.bukaForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kategori'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadKategori,
        child: Obx(() {
          if (controller.isLoading.value && controller.kategori.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null && controller.kategori.isEmpty) {
            return EmptyState.error(controller.errorMessage.value!, controller.loadKategori);
          }
          if (controller.kategori.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: 'Belum ada kategori',
              actionLabel: 'Tambah Kategori',
              onAction: controller.bukaForm,
            );
          }
          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                itemCount: controller.kategori.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final k = controller.kategori[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFDDF5D0),
                        child: Icon(CategoryChip.iconFor(k.ikon), color: AppColors.teal),
                      ),
                      title: Text(k.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${k.jumlahProduk} produk${k.deskripsi == null ? '' : '\n${k.deskripsi}'}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      isThreeLine: k.deskripsi != null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Ubah',
                            onPressed: () => controller.bukaForm(k),
                            icon: const Icon(Icons.edit_rounded, color: AppColors.teal),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => controller.hapus(k),
                            icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (controller.isLoading.value) const LinearProgressIndicator(),
            ],
          );
        }),
      ),
    );
  }
}
