import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/config/env.dart';
import '../../data/models/order_model.dart';

class OrdersController extends GetxController {
  final api = ApiService();

  RxBool loading = false.obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxInt filterIndex =
      0.obs; // 0 الكل - 1 قيد التقديم - 2 تحت التجهيز - 3 فاشلات
  RxString search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      loading(true);
      final data = await api.get(Env.ordersList);
      final list = (data as List).map((e) => OrderModel.fromJson(e)).toList();
      orders.assignAll(list);
    } catch (e) {
      Get.snackbar('خطأ', '$e');
    } finally {
      loading(false);
    }
  }

  List<OrderModel> get filtered {
    final f = filterIndex.value;
    final q = search.value.trim();
    return orders.where((o) {
      final byFilter = switch (f) {
        0 => true,
        1 => o.status == 'pending',
        2 => o.status == 'processing',
        3 => o.status == 'cancelled',
        _ => true,
      };
      final bySearch =
          q.isEmpty ||
          o.customerName.contains(q) ||
          o.phone.contains(q) ||
          '${o.id}'.contains(q);
      return byFilter && bySearch;
    }).toList();
  }
}
