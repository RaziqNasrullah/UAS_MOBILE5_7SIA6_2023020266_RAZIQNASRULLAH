import 'package:get/get.dart';

import '../controllers/produk_controller.dart';

class ProdukBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ProdukController());
}

class ProdukFormBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ProdukFormController());
}
