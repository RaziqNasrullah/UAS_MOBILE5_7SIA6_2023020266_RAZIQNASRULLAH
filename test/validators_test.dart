import 'package:flutter_test/flutter_test.dart';
import 'package:myhealthgw/app/utils/validators.dart';

void main() {
  group('Validators.namaKategori', () {
    const existing = ['Obat Bebas', 'Vitamin & Suplemen'];

    test('kosong ditolak', () {
      expect(Validators.namaKategori('   ', existing), isNotNull);
    });

    test('duplikat case-insensitive ditolak', () {
      expect(Validators.namaKategori('obat bebas', existing), 'Nama kategori sudah digunakan');
    });

    test('nama baru diterima', () {
      expect(Validators.namaKategori('Ibu & Anak', existing), isNull);
    });
  });

  group('Validators.noHp', () {
    test('harus diawali 08', () => expect(Validators.noHp('0712345678'), isNotNull));
    test('minimal 10 digit', () => expect(Validators.noHp('08123'), isNotNull));
    test('maksimal 13 digit', () => expect(Validators.noHp('08123456789012'), isNotNull));
    test('hanya angka', () => expect(Validators.noHp('0812abc4567'), isNotNull));
    test('valid 12 digit', () => expect(Validators.noHp('081234567890'), isNull));
  });

  group('Validators harga & stok', () {
    test('harga 0 ditolak', () => expect(Validators.harga('0'), isNotNull));
    test('harga bukan angka ditolak', () => expect(Validators.harga('abc'), isNotNull));
    test('harga valid', () => expect(Validators.harga('8500'), isNull));
    test('stok negatif ditolak', () => expect(Validators.stok('-1'), isNotNull));
    test('stok 0 diterima', () => expect(Validators.stok('0'), isNull));
  });
}
