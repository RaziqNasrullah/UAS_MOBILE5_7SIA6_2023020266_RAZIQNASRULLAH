import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/api_config.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Menu admin apotek: dashboard, kelola kategori, kelola produk.
class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Apotek')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE3ECE6)),
            ),
            child: Row(
              children: [
                Image.asset('assets/logo/logo_icon.png', width: 56, height: 56),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ApiConfig.namaToko,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.teal)),
                      Text('Panel pengelolaan apotek',
                          style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _menu(
            icon: Icons.insights_rounded,
            color: AppColors.teal,
            title: 'Dashboard Penjualan',
            subtitle: 'Total pesanan, pendapatan, produk terlaris & grafik',
            route: Routes.dashboard,
          ),
          _menu(
            icon: Icons.category_rounded,
            color: AppColors.primaryDark,
            title: 'Kelola Kategori',
            subtitle: 'Tambah, ubah, dan hapus kategori produk',
            route: Routes.kategori,
          ),
          _menu(
            icon: Icons.medication_rounded,
            color: AppColors.accent,
            title: 'Kelola Produk',
            subtitle: 'Produk, stok, golongan obat, aturan pakai & gambar',
            route: Routes.produk,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dns_rounded, size: 18, color: AppColors.teal),
                      SizedBox(width: 6),
                      Text('Server API', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const SelectableText(ApiConfig.baseUrl,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text(
                    'Ubah di lib/app/data/services/api_config.dart atau jalankan dengan '
                    '--dart-define=API_BASE_URL=http://<ip-laptop>/apotek_api',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const Divider(height: 22),
                  const Text('${ApiConfig.namaAplikasi} v1.0.0 • ${ApiConfig.pembuat}',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Get.toNamed(route),
        ),
      ),
    );
  }
}
