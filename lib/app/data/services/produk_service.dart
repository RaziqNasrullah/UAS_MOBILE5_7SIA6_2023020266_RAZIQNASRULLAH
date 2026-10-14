import 'dart:io';

import 'package:get/get.dart';

import '../../models/produk.dart';
import 'api_service.dart';

class ProdukService {
  ApiService get _api => Get.find<ApiService>();

  /// Ambil produk dengan pencarian nama & filter kategori (dikombinasikan di server).
  Future<List<Produk>> getAll({
    String? search,
    int? kategoriId,
    bool unggulan = false,
    int? limit,
    bool terbaru = false,
  }) async {
    final res = await _api.get('produk/read.php', query: {
      'search': search,
      'kategori_id': kategoriId,
      'unggulan': unggulan ? 1 : null,
      'limit': limit,
      'sort': terbaru ? 'terbaru' : null,
    });
    return (res.data as List? ?? [])
        .map((e) => Produk.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Produk> getDetail(int id) async {
    final res = await _api.get('produk/detail.php', query: {'id': id});
    return Produk.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<String> create(Produk produk) async {
    final res = await _api.post('produk/create.php', produk.toJson());
    return res.message;
  }

  Future<String> update(Produk produk) async {
    final res = await _api.post('produk/update.php', produk.toJson());
    return res.message;
  }

  Future<String> delete(int id) async {
    final res = await _api.post('produk/delete.php', {'id': id});
    return res.message;
  }

  /// Upload gambar, mengembalikan nama file yang tersimpan di server.
  Future<String> uploadGambar(File file) async {
    final res = await _api.upload('produk/upload_gambar.php', 'gambar', file);
    return (res.data as Map)['gambar'].toString();
  }
}
