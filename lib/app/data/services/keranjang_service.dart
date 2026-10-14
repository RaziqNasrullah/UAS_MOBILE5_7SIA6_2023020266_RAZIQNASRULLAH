import 'package:get/get.dart';

import '../../models/keranjang_item.dart';
import 'api_service.dart';

class KeranjangResult {
  final List<KeranjangItem> items;
  final String message;

  KeranjangResult(this.items, this.message);
}

class KeranjangService {
  ApiService get _api => Get.find<ApiService>();

  KeranjangResult _parse(ApiResponse res) {
    final items = ((res.data as Map?)?['items'] as List? ?? [])
        .map((e) => KeranjangItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return KeranjangResult(items, res.message);
  }

  Future<KeranjangResult> getAll() async =>
      _parse(await _api.get('keranjang/read.php'));

  Future<KeranjangResult> add(int produkId, {int jumlah = 1}) async => _parse(
      await _api.post('keranjang/add.php', {'produk_id': produkId, 'jumlah': jumlah}));

  Future<KeranjangResult> updateQty(int id, int jumlah) async => _parse(
      await _api.post('keranjang/update_qty.php', {'id': id, 'jumlah': jumlah}));

  Future<KeranjangResult> delete(int id) async =>
      _parse(await _api.post('keranjang/delete.php', {'id': id}));

  Future<KeranjangResult> clear() async =>
      _parse(await _api.post('keranjang/clear.php'));
}
