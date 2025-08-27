// lib/core/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:iforenta_admin_2/controllers/orders_controller.dart';
import 'package:iforenta_admin_2/views/dashboard_view.dart';
import 'package:iforenta_admin_2/views/orders_view.dart';
import 'dashboard_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.dashboard;

  static final pages = <GetPage>[
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(), // <-- مهم
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrdersController>(() => OrdersController());
      }),
    ),
  ];
}
