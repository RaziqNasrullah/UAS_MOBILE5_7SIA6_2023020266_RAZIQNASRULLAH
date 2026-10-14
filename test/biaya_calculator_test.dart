import 'package:flutter_test/flutter_test.dart';
import 'package:myhealthgw/app/models/pesanan.dart';
import 'package:myhealthgw/app/utils/biaya_calculator.dart';

void main() {
  test('ambil di tempat tanpa diskon', () {
    final r = RincianBiaya.hitung(50000, MetodePengambilan.ambil);
    expect(r.biayaLayanan, 2000);
    expect(r.ongkir, 0);
    expect(r.diskon, 0);
    expect(r.total, 52000);
  });

  test('diantar dengan diskon 10% (subtotal >= 150.000)', () {
    final r = RincianBiaya.hitung(360000, MetodePengambilan.diantar);
    expect(r.ongkir, 10000);
    expect(r.diskon, 36000);
    expect(r.total, 360000 + 2000 + 10000 - 36000);
  });

  test('tepat di batas 150.000 mendapat diskon', () {
    expect(RincianBiaya.hitung(150000, MetodePengambilan.ambil).diskon, 15000);
    expect(RincianBiaya.hitung(149999, MetodePengambilan.ambil).diskon, 0);
  });

  test('keranjang kosong = 0', () {
    expect(RincianBiaya.hitung(0, MetodePengambilan.diantar).total, 0);
  });
}
