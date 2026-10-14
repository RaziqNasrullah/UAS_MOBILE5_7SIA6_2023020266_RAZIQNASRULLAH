import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_summary.dart';
import '../../models/pesanan.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/summary_card.dart';

/// Dashboard penjualan: kartu ringkasan + grafik fl_chart.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penjualan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: controller.loadSummary,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadSummary,
        child: Obx(() {
          final s = controller.summary.value;
          if (controller.isLoading.value && s == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null && s == null) {
            return EmptyState.error(controller.errorMessage.value!, controller.loadSummary);
          }
          if (s == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  SummaryCard(
                    title: 'Total Pesanan',
                    value: '${s.totalPesanan}',
                    icon: Icons.receipt_long_rounded,
                    caption: 'Semua status',
                  ),
                  SummaryCard(
                    title: 'Total Pendapatan',
                    value: Formatter.rupiah(s.totalPendapatan),
                    icon: Icons.payments_rounded,
                    color: AppColors.success,
                    caption: 'Hanya pesanan Selesai',
                  ),
                  SummaryCard(
                    title: 'Produk Terlaris',
                    value: s.produkTerlaris.isEmpty ? '-' : '${s.produkTerlaris.first.totalTerjual} terjual',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.accent,
                    caption: s.produkTerlaris.isEmpty ? 'Belum ada penjualan' : s.produkTerlaris.first.namaProduk,
                  ),
                  SummaryCard(
                    title: 'Jumlah Produk',
                    value: '${s.jumlahProduk}',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.tealLight,
                    caption: '${s.produkStokHabis} produk stok habis',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _statusRow(s),
              const SizedBox(height: 6),
              const Text(
                'Total pendapatan dihitung dari pesanan berstatus "Selesai". '
                'Produk terlaris dihitung dari jumlah terjual, tidak termasuk pesanan "Dibatalkan".',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              _chartCard(
                context,
                title: '5 Produk Terlaris',
                subtitle: 'Jumlah unit terjual',
                child: s.produkTerlaris.isEmpty
                    ? const Center(child: Text('Belum ada data penjualan'))
                    : _barChart(s.produkTerlaris),
                legend: _legendTerlaris(s.produkTerlaris),
              ),
              const SizedBox(height: 14),
              _chartCard(
                context,
                title: 'Pendapatan 7 Hari Terakhir',
                subtitle: 'Pesanan berstatus Selesai',
                child: _lineChart(s.pendapatanHarian),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _statusRow(DashboardSummary s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: StatusPesanan.all.map((st) {
            final color = AppColors.status(st);
            return Expanded(
              child: Column(
                children: [
                  Text('${s.pesananPerStatus[st] ?? 0}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
                  Text(st, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _chartCard(BuildContext context,
      {required String title, required String subtitle, required Widget child, Widget? legend}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            SizedBox(height: 220, child: child),
            if (legend != null) ...[const SizedBox(height: 10), legend],
          ],
        ),
      ),
    );
  }

  static const _barColors = [
    AppColors.teal,
    AppColors.primaryDark,
    AppColors.accent,
    AppColors.tealLight,
    Color(0xFF7A9A2E),
  ];

  Widget _barChart(List<ProdukTerlaris> data) {
    final maxY = data.map((e) => e.totalTerjual).reduce(math.max).toDouble();
    return BarChart(
      BarChartData(
        maxY: (maxY * 1.25).ceilToDouble().clamp(4, double.infinity),
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textDark,
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${data[group.x].namaProduk}\n${rod.toY.toInt()} terjual',
              const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => value % 1 == 0
                  ? Text(value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted))
                  : const SizedBox.shrink(),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('#${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: data[i].totalTerjual.toDouble(),
                width: 24,
                color: _barColors[i % _barColors.length],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _legendTerlaris(List<ProdukTerlaris> data) {
    return Column(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _barColors[i % _barColors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text('#${i + 1} ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Expanded(
                  child: Text(data[i].namaProduk,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                ),
                Text('${data[i].totalTerjual}x',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _lineChart(List<PendapatanHarian> data) {
    if (data.isEmpty) return const Center(child: Text('Belum ada data'));
    final maxY = data.map((e) => e.pendapatan).fold<double>(0, math.max);
    final top = maxY <= 0 ? 100000.0 : maxY * 1.25;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: top,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: top / 4,
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textDark,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${Formatter.tanggalPendek(data[s.x.toInt()].tanggal)}\n${Formatter.rupiah(s.y)}',
                      const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ))
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: top / 4,
              getTitlesWidget: (value, meta) => Text(Formatter.rupiahSingkat(value),
                  style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length || value != i.toDouble()) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(Formatter.tanggalPendek(data[i].tanggal),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].pendapatan),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.teal,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.45),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
