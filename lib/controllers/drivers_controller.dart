import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/config/env.dart';

/// هيكل بسيط: (id, name, phone)
class DriversController extends GetxController {
  final _api = ApiService();

  RxBool loading = false.obs;
  RxList<(int, String, String)> drivers = <(int, String, String)>[].obs;

  Future<void> fetchDrivers() async {
    try {
      loading(true);
      final data = await _api.get(Env.driversList);
      // توقّع: [{id,name,phone}, ...]
      drivers.assignAll(
        (data as List).map((e) {
          final id = int.tryParse('${e['id'] ?? 0}') ?? 0;
          final name = (e['name'] ?? '').toString();
          final phone = (e['phone'] ?? '').toString();
          return (id, name, phone);
        }),
      );
    } finally {
      loading(false);
    }
  }

  Future<void> assignOrderToDriver({
    required int orderId,
    required int driverId,
  }) async {
    await _api.postForm(Env.orderAssignDriver, {
      'order_id': '$orderId',
      'driver_id': '$driverId',
    });
    Get.snackbar('تم', 'تم تكليف السائق بنجاح');
  }
}
