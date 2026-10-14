import 'package:get/get.dart';

import '../controllers/pesanan_controller.dart';

class PesananDetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => PesananDetailController());
}
