import 'detail_pesanan.dart';
import 'json_parser.dart';

class StatusPesanan {
  static const diproses = 'Diproses';
  static const selesai = 'Selesai';
  static const dibatalkan = 'Dibatalkan';

  static const all = [diproses, selesai, dibatalkan];
}

class MetodePengambilan {
  static const ambil = 'Ambil di Tempat';
  static const diantar = 'Diantar';

  static const all = [ambil, diantar];
}

class Pesanan {
  final int id;
  final String nomorPesanan;
  final String namaPemesan;
  final String noHp;
  final String metodePengambilan;
  final String? alamat;
  final String? catatan;
  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;
  final double total;
  final String status;
  final DateTime tanggal;
  final int jumlahItem;
  final List<DetailPesanan> items;

  const Pesanan({
    required this.id,
    required this.nomorPesanan,
    required this.namaPemesan,
    required this.noHp,
    required this.metodePengambilan,
    this.alamat,
    this.catatan,
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
    required this.total,
    required this.status,
    required this.tanggal,
    this.jumlahItem = 0,
    this.items = const [],
  });

  bool get bisaDiubah => status == StatusPesanan.diproses;

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? [])
        .map((e) => DetailPesanan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return Pesanan(
      id: asInt(json['id']),
      nomorPesanan: json['nomor_pesanan']?.toString() ?? '',
      namaPemesan: json['nama_pemesan']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      metodePengambilan:
          json['metode_pengambilan']?.toString() ?? MetodePengambilan.ambil,
      alamat: asStringOrNull(json['alamat']),
      catatan: asStringOrNull(json['catatan']),
      subtotal: asDouble(json['subtotal']),
      biayaLayanan: asDouble(json['biaya_layanan']),
      ongkir: asDouble(json['ongkir']),
      diskon: asDouble(json['diskon']),
      total: asDouble(json['total']),
      status: json['status']?.toString() ?? StatusPesanan.diproses,
      tanggal: asDate(json['tanggal']) ?? DateTime.now(),
      jumlahItem: asInt(json['jumlah_item'],
          items.fold<int>(0, (sum, e) => sum + e.jumlah)),
      items: items,
    );
  }
}
