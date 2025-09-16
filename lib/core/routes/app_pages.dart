import 'package:get/get.dart';
import 'package:iforenta_admin_2/controllers/drivers_controller.dart';
import 'package:iforenta_admin_2/controllers/profile_controller.dart';
import 'package:iforenta_admin_2/controllers/users_controller.dart';
import 'package:iforenta_admin_2/views/categories_view.dart';
import 'package:iforenta_admin_2/views/dashboard_view.dart';
import 'package:iforenta_admin_2/views/drivers_view.dart';
import 'package:iforenta_admin_2/views/gate/decide_gate.dart';
import 'package:iforenta_admin_2/views/items_view.dart';
import 'package:iforenta_admin_2/views/login_view.dart';
import 'package:iforenta_admin_2/views/offers_view.dart';
import 'package:iforenta_admin_2/views/orders_view.dart';
import 'package:iforenta_admin_2/views/profile_view.dart';
import 'package:iforenta_admin_2/views/receiver/receiver_home_view.dart';
import 'package:iforenta_admin_2/views/users_view.dart' show UsersView;
import '../../controllers/dashboard_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/categories_controller.dart';
import '../../controllers/items_controller.dart';
import '../../controllers/offers_controller.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.dashboard;

  static final pages = <GetPage>[
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrdersController>(() => OrdersController());
      }),
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoriesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CategoriesController>(() => CategoriesController());
      }),
    ),
    GetPage(
      name: Routes.items,
      page: () => ItemsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ItemsController>(() => ItemsController());
      }),
    ),
    GetPage(
      name: Routes.offers,
      page: () => const OffersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OffersController>(() => OffersController());
      }),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.users,
      page: () => const UsersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<UsersController>(() => UsersController());
      }),
    ),
    GetPage(
      name: Routes.drivers,
      page: () => const DriversView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DriversController>(() => DriversController());
      }),
    ),
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(
      name: Routes.decide,
      page: () => const DecideGate(), // يقرر حسب الجلسة/الدور
    ),
    GetPage(name: Routes.receiverHome, page: () => const ReceiverHomeView()),
  ];
}
