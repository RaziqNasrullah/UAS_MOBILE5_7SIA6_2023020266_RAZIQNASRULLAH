import 'json_parser.dart';

class ProdukTerlaris {
  final int? produkId;
  final String namaProduk;
  final int totalTerjual;
  final double totalPenjualan;

  const ProdukTerlaris({
    this.produkId,
    required this.namaProduk,
    required this.totalTerjual,
    required this.totalPenjualan,
  });

  factory ProdukTerlaris.fromJson(Map<String, dynamic> json) => ProdukTerlaris(
        produkId: json['produk_id'] == null ? null : asInt(json['produk_id']),
        namaProduk: json['nama_produk']?.toString() ?? '',
        totalTerjual: asInt(json['total_terjual']),
        totalPenjualan: asDouble(json['total_penjualan']),
      );
}

class PendapatanHarian {
  final DateTime tanggal;
  final double pendapatan;

  const PendapatanHarian({required this.tanggal, required this.pendapatan});

  factory PendapatanHarian.fromJson(Map<String, dynamic> json) =>
      PendapatanHarian(
        tanggal: asDate(json['tanggal']) ?? DateTime.now(),
        pendapatan: asDouble(json['pendapatan']),
      );
}

class DashboardSummary {
  final int totalPesanan;
  final Map<String, int> pesananPerStatus;
  final double totalPendapatan;
  final List<ProdukTerlaris> produkTerlaris;
  final List<PendapatanHarian> pendapatanHarian;
  final int jumlahProduk;
  final int produkStokHabis;

  const DashboardSummary({
    required this.totalPesanan,
    required this.pesananPerStatus,
    required this.totalPendapatan,
    required this.produkTerlaris,
    required this.pendapatanHarian,
    required this.jumlahProduk,
    required this.produkStokHabis,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final status = <String, int>{};
    (json['pesanan_per_status'] as Map? ?? {})
        .forEach((k, v) => status[k.toString()] = asInt(v));
    return DashboardSummary(
      totalPesanan: asInt(json['total_pesanan']),
      pesananPerStatus: status,
      totalPendapatan: asDouble(json['total_pendapatan']),
      produkTerlaris: (json['produk_terlaris'] as List? ?? [])
          .map((e) => ProdukTerlaris.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pendapatanHarian: (json['pendapatan_harian'] as List? ?? [])
          .map((e) => PendapatanHarian.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      jumlahProduk: asInt(json['jumlah_produk']),
      produkStokHabis: asInt(json['produk_stok_habis']),
    );
  }
}
