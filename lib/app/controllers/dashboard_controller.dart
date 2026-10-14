import 'package:get/get.dart';

import '../data/services/dashboard_service.dart';
import '../models/dashboard_summary.dart';

class DashboardController extends GetxController {
  final DashboardService _service = Get.find<DashboardService>();

  final summary = Rxn<DashboardSummary>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  Future<void> loadSummary() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      summary.value = await _service.getSummary();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
