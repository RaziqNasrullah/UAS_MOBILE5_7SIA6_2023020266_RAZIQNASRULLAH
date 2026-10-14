import 'package:get/get.dart';

import '../../models/kategori.dart';
import 'api_service.dart';

class KategoriService {
  ApiService get _api => Get.find<ApiService>();

  Future<List<Kategori>> getAll() async {
    final res = await _api.get('kategori/read.php');
    return (res.data as List? ?? [])
        .map((e) => Kategori.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> create(String nama, String deskripsi) async {
    final res = await _api
        .post('kategori/create.php', {'nama': nama, 'deskripsi': deskripsi});
    return res.message;
  }

  Future<String> update(int id, String nama, String deskripsi) async {
    final res = await _api.post(
        'kategori/update.php', {'id': id, 'nama': nama, 'deskripsi': deskripsi});
    return res.message;
  }

  Future<String> delete(int id) async {
    final res = await _api.post('kategori/delete.php', {'id': id});
    return res.message;
  }
}
