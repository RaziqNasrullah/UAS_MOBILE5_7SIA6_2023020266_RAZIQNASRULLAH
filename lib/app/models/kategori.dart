import 'json_parser.dart';

class Kategori {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? ikon;
  final int jumlahProduk;

  const Kategori({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.ikon,
    this.jumlahProduk = 0,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
        id: asInt(json['id']),
        nama: json['nama']?.toString() ?? '',
        deskripsi: asStringOrNull(json['deskripsi']),
        ikon: asStringOrNull(json['ikon']),
        jumlahProduk: asInt(json['jumlah_produk']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'ikon': ikon,
      };
}
