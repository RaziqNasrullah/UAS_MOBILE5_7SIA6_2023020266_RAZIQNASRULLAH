import 'json_parser.dart';

class KeranjangItem {
  final int id;
  final int produkId;
  final String nama;
  final String namaKategori;
  final double harga;
  final int stok;
  final String? gambar;
  final String golonganObat;
  final int jumlah;

  const KeranjangItem({
    required this.id,
    required this.produkId,
    required this.nama,
    required this.namaKategori,
    required this.harga,
    required this.stok,
    this.gambar,
    required this.golonganObat,
    required this.jumlah,
  });

  /// Subtotal per item dihitung di sisi aplikasi agar langsung reaktif.
  double get subtotal => harga * jumlah;

  factory KeranjangItem.fromJson(Map<String, dynamic> json) => KeranjangItem(
        id: asInt(json['id']),
        produkId: asInt(json['produk_id']),
        nama: json['nama']?.toString() ?? '',
        namaKategori: json['nama_kategori']?.toString() ?? '-',
        harga: asDouble(json['harga']),
        stok: asInt(json['stok']),
        gambar: asStringOrNull(json['gambar']),
        golonganObat: json['golongan_obat']?.toString() ?? '',
        jumlah: asInt(json['jumlah'], 1),
      );

  KeranjangItem copyWith({int? jumlah}) => KeranjangItem(
        id: id,
        produkId: produkId,
        nama: nama,
        namaKategori: namaKategori,
        harga: harga,
        stok: stok,
        gambar: gambar,
        golonganObat: golonganObat,
        jumlah: jumlah ?? this.jumlah,
      );
}
