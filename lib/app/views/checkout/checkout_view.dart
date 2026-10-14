import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/checkout_controller.dart';
import '../../data/services/api_config.dart';
import '../../models/pesanan.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import 'rincian_biaya_card.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Obx(() {
        if (controller.cart.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Keranjang kosong',
            message: 'Tambahkan produk terlebih dahulu sebelum checkout.',
            actionLabel: 'Kembali',
            onAction: Get.back,
          );
        }
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _title(context, Icons.person_rounded, 'Data Pemesan'),
              CustomTextField(
                controller: controller.namaCtrl,
                label: 'Nama pemesan *',
                icon: Icons.badge_rounded,
                maxLength: 100,
                validator: (v) => Validators.wajib(v, 'Nama pemesan'),
              ),
              CustomTextField(
                controller: controller.noHpCtrl,
                label: 'Nomor HP *',
                hint: '08xxxxxxxxxx',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: Validators.noHp,
              ),
              _title(context, Icons.local_shipping_rounded, 'Metode Pengambilan'),
              Obx(() => RadioGroup<String>(
                    groupValue: controller.metode.value,
                    onChanged: (v) {
                      if (v != null) controller.metode.value = v;
                    },
                    child: Column(
                    children: MetodePengambilan.all.map((m) {
                      final selected = controller.metode.value == m;
                      final diantar = m == MetodePengambilan.diantar;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => controller.metode.value = m,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFFEFF9EA) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? AppColors.primaryDark : const Color(0xFFD7E2DC),
                                width: selected ? 1.6 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio<String>(value: m),
                                Icon(diantar ? Icons.delivery_dining_rounded : Icons.storefront_rounded,
                                    color: AppColors.teal),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text(
                                        diantar
                                            ? 'Ongkir ${Formatter.rupiah(ApiConfig.ongkirDiantar)}'
                                            : 'Gratis, ambil di ${ApiConfig.namaToko}',
                                        style: const TextStyle(
                                            fontSize: 12, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ))),
              // Alamat hanya muncul (dan wajib) jika metode = Diantar.
              Obx(() => AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: controller.isDiantar
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: CustomTextField(
                              controller: controller.alamatCtrl,
                              label: 'Alamat pengantaran *',
                              icon: Icons.location_on_rounded,
                              maxLines: 3,
                              validator: controller.validateAlamat,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  )),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.catatanCtrl,
                label: 'Catatan (opsional)',
                hint: 'Contoh: titip di satpam',
                icon: Icons.edit_note_rounded,
                maxLines: 2,
              ),
              _title(context, Icons.shopping_bag_rounded, 'Ringkasan Pesanan'),
              Card(
                child: Column(
                  children: controller.cart.items
                      .map((e) => ListTile(
                            dense: true,
                            title: Text(e.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${e.jumlah} x ${Formatter.rupiah(e.harga)}'),
                            trailing: Text(Formatter.rupiah(e.subtotal),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final r = controller.rincian;
                return RincianBiayaCard(
                  subtotal: r.subtotal,
                  biayaLayanan: r.biayaLayanan,
                  ongkir: r.ongkir,
                  diskon: r.diskon,
                  total: r.total,
                  jumlahItem: controller.cart.totalItem,
                );
              }),
              const SizedBox(height: 6),
              Text(
                'Biaya layanan ${Formatter.rupiah(ApiConfig.biayaLayanan)} • '
                'Diskon ${ApiConfig.persenDiskon.toInt()}% untuk subtotal ≥ ${Formatter.rupiah(ApiConfig.minSubtotalDiskon)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => controller.cart.isEmpty
          ? const SizedBox.shrink()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value ? null : controller.submit,
                  icon: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(controller.isSubmitting.value
                      ? 'Memproses pesanan...'
                      : 'Buat Pesanan • ${Formatter.rupiah(controller.rincian.total)}'),
                ),
              ),
            )),
    );
  }

  Widget _title(BuildContext context, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.teal, size: 20),
            const SizedBox(width: 8),
            Text(text, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}
