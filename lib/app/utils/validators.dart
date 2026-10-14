/// Kumpulan validator form. Mengembalikan pesan error atau null jika valid.
class Validators {
  Validators._();

  static String? wajib(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  /// Nama kategori: wajib & tidak boleh sama (case-insensitive) dengan yang sudah ada.
  static String? namaKategori(String? v, Iterable<String> namaLain) {
    final err = wajib(v, 'Nama kategori');
    if (err != null) return err;
    final nama = v!.trim().toLowerCase();
    if (namaLain.any((n) => n.trim().toLowerCase() == nama)) {
      return 'Nama kategori sudah digunakan';
    }
    if (v.trim().length > 100) return 'Maksimal 100 karakter';
    return null;
  }

  static String? harga(String? v) {
    final err = wajib(v, 'Harga');
    if (err != null) return err;
    final n = double.tryParse(v!.trim().replaceAll('.', '').replaceAll(',', '.'));
    if (n == null) return 'Harga harus berupa angka';
    if (n <= 0) return 'Harga harus lebih dari 0';
    return null;
  }

  static String? stok(String? v) {
    final err = wajib(v, 'Stok');
    if (err != null) return err;
    final n = int.tryParse(v!.trim());
    if (n == null) return 'Stok harus berupa bilangan bulat';
    if (n < 0) return 'Stok tidak boleh negatif';
    return null;
  }

  /// No HP: angka 10-13 digit, diawali 08.
  static String? noHp(String? v) {
    final err = wajib(v, 'Nomor HP');
    if (err != null) return err;
    final s = v!.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^[0-9]+$').hasMatch(s)) return 'Nomor HP hanya boleh angka';
    if (!s.startsWith('08')) return 'Nomor HP harus diawali 08';
    if (s.length < 10 || s.length > 13) return 'Nomor HP harus 10-13 digit';
    return null;
  }

  static double parseHarga(String v) =>
      double.parse(v.trim().replaceAll('.', '').replaceAll(',', '.'));
}
