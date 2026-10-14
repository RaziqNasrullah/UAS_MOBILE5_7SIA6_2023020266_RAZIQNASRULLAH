import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myhealthgw/app/models/pesanan.dart';
import 'package:myhealthgw/app/models/produk.dart';
import 'package:myhealthgw/app/utils/pdf_generator.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('id_ID'));

  final pesananJson = {
    'id': 7,
    'nomor_pesanan': 'INV-20261014-003',
    'nama_pemesan': 'Raziq Nasrullah',
    'no_hp': '081234567890',
    'metode_pengambilan': 'Diantar',
    'alamat': 'Jl. Kampus No. 1',
    'catatan': null,
    'subtotal': 160000.0,
    'biaya_layanan': 2000.0,
    'ongkir': 10000.0,
    'diskon': 16000.0,
    'total': 156000.0,
    'status': 'Diproses',
    'tanggal': '2026-10-14 10:30:00',
    'items': [
      {
        'id': 1, 'pesanan_id': 7, 'produk_id': 13,
        'nama_produk': 'Tensimeter Digital Lengan Atas',
        'harga_satuan': '125000.00', 'jumlah': 1, 'subtotal': 125000,
      },
      {
        'id': 2, 'pesanan_id': 7, 'produk_id': null,
        'nama_produk': 'Termometer Digital — Ujung Fleksibel',
        'harga_satuan': 35000, 'jumlah': 1, 'subtotal': 35000,
      },
    ],
  };

  test('Produk.fromJson membaca nama kategori hasil JOIN', () {
    final p = Produk.fromJson({
      'id': '1', 'kategori_id': 1, 'nama_kategori': 'Obat Bebas', 'nama': 'Parasetamol',
      'harga': '8500.00', 'stok': '0', 'deskripsi': 'd', 'gambar': null,
      'golongan_obat': 'Obat Bebas', 'aturan_pakai': 'a', 'is_unggulan': 1,
    });
    expect(p.namaKategori, 'Obat Bebas');
    expect(p.harga, 8500);
    expect(p.stokHabis, isTrue);
    expect(p.isUnggulan, isTrue);
  });

  test('Pesanan.fromJson + item snapshot', () {
    final p = Pesanan.fromJson(pesananJson);
    expect(p.items.length, 2);
    expect(p.jumlahItem, 2);
    expect(p.items.first.hargaSatuan, 125000);
    expect(p.items.last.produkId, isNull);
    expect(p.bisaDiubah, isTrue);
  });

  test('Struk PDF berhasil dibuat', () async {
    final bytes = await PdfGenerator.buildStruk(Pesanan.fromJson(pesananJson));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final out = Platform.environment['STRUK_OUT'];
    if (out != null) await File(out).writeAsBytes(bytes);
  });
}
