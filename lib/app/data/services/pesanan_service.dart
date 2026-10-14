import 'package:get/get.dart';

import '../../models/pesanan.dart';
import 'api_service.dart';

class PesananService {
  ApiService get _api => Get.find<ApiService>();

  Future<Pesanan> checkout({
    required String namaPemesan,
    required String noHp,
    required String metodePengambilan,
    String? alamat,
    String? catatan,
  }) async {
    final res = await _api.post('pesanan/checkout.php', {
      'nama_pemesan': namaPemesan,
      'no_hp': noHp,
      'metode_pengambilan': metodePengambilan,
      'alamat': alamat ?? '',
      'catatan': catatan ?? '',
    });
    return Pesanan.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<List<Pesanan>> getAll({String? status}) async {
    final res = await _api.get('pesanan/read.php', query: {'status': status});
    return (res.data as List? ?? [])
        .map((e) => Pesanan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Pesanan> getDetail(int id) async {
    final res = await _api.get('pesanan/detail.php', query: {'id': id});
    return Pesanan.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<(Pesanan, String)> updateStatus(int id, String status) async {
    final res = await _api
        .post('pesanan/update_status.php', {'id': id, 'status': status});
    return (Pesanan.fromJson(Map<String, dynamic>.from(res.data)), res.message);
  }
}
