import 'json_parser.dart';

/// Daftar golongan obat sesuai ENUM di database.
class GolonganObat {
  static const bebas = 'Obat Bebas';
  static const bebasTerbatas = 'Obat Bebas Terbatas';
  static const keras = 'Obat Keras';
  static const herbal = 'Jamu/Herbal';
  static const nonObat = 'Non-Obat';

  static const all = [bebas, bebasTerbatas, keras, herbal, nonObat];
}

class Produk {
  final int id;
  final int kategoriId;
  final String namaKategori;
  final String nama;
  final double harga;
  final int stok;
  final String deskripsi;
  final String? gambar;
  final String golonganObat;
  final String aturanPakai;
  final bool isUnggulan;
  final DateTime? createdAt;

  const Produk({
    required this.id,
    required this.kategoriId,
    required this.namaKategori,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    this.gambar,
    required this.golonganObat,
    required this.aturanPakai,
    this.isUnggulan = false,
    this.createdAt,
  });

  bool get stokHabis => stok <= 0;

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
        id: asInt(json['id']),
        kategoriId: asInt(json['kategori_id']),
        namaKategori: json['nama_kategori']?.toString() ?? '-',
        nama: json['nama']?.toString() ?? '',
        harga: asDouble(json['harga']),
        stok: asInt(json['stok']),
        deskripsi: json['deskripsi']?.toString() ?? '',
        gambar: asStringOrNull(json['gambar']),
        golonganObat: json['golongan_obat']?.toString() ?? GolonganObat.nonObat,
        aturanPakai: json['aturan_pakai']?.toString() ?? '',
        isUnggulan: asInt(json['is_unggulan']) == 1,
        createdAt: asDate(json['created_at']),
      );

  /// Body untuk create/update ke API.
  Map<String, dynamic> toJson() => {
        if (id > 0) 'id': id,
        'kategori_id': kategoriId,
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'deskripsi': deskripsi,
        'gambar': gambar ?? '',
        'golongan_obat': golonganObat,
        'aturan_pakai': aturanPakai,
        'is_unggulan': isUnggulan ? 1 : 0,
      };
}
