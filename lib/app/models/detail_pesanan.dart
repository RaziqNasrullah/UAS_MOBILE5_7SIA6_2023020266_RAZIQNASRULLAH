import 'json_parser.dart';

class DetailPesanan {
  final int id;
  final int pesananId;
  final int? produkId;
  final String namaProduk;
  final double hargaSatuan;
  final int jumlah;
  final double subtotal;

  const DetailPesanan({
    required this.id,
    required this.pesananId,
    this.produkId,
    required this.namaProduk,
    required this.hargaSatuan,
    required this.jumlah,
    required this.subtotal,
  });

  factory DetailPesanan.fromJson(Map<String, dynamic> json) => DetailPesanan(
        id: asInt(json['id']),
        pesananId: asInt(json['pesanan_id']),
        produkId: json['produk_id'] == null ? null : asInt(json['produk_id']),
        namaProduk: json['nama_produk']?.toString() ?? '',
        hargaSatuan: asDouble(json['harga_satuan']),
        jumlah: asInt(json['jumlah']),
        subtotal: asDouble(json['subtotal']),
      );
}
