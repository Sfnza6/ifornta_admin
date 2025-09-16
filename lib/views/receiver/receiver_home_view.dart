import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iforenta_admin_2/views/receiver/receiver_assign_page.dart';
import 'package:iforenta_admin_2/views/receiver/receiver_items_view.dart';
import 'package:iforenta_admin_2/views/receiver/receiver_orders_view.dart';

import '../../controllers/orders_controller.dart';
import '../../controllers/items_controller.dart';
import '../../controllers/AuthController.dart';
import '../../core/routes/app_routes.dart';

class ReceiverHomeView extends StatefulWidget {
  const ReceiverHomeView({super.key});

  @override
  State<ReceiverHomeView> createState() => _ReceiverHomeViewState();
}

class _ReceiverHomeViewState extends State<ReceiverHomeView> {
  static const brown = Color(0xFF6F3F17);
  static const pageBg = Color(0xFFF3F0ED);

  int _index = 0;

  @override
  void initState() {
    super.initState();
    // تأكد من وجود الكنترولات
    if (!Get.isRegistered<OrdersController>()) {
      Get.put(OrdersController(), permanent: false);
    }
    if (!Get.isRegistered<ItemsController>()) {
      Get.put(ItemsController(), permanent: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final pages = const [
      ReceiverOrdersPage(),
      ReceiverItemsPage(),
      ReceiverAssignPage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: brown,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'مستقبل الطلبات',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              tooltip: 'تسجيل خروج',
              onPressed: () async {
                await auth.logout();
                Get.offAllNamed(Routes.login);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),
        body: pages[_index],
        bottomNavigationBar: _BottomNav(
          current: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onChanged});
  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: NavigationBar(
        height: 64,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF3F0ED),
        selectedIndex: current,
        onDestinationSelected: onChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'الأصناف',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'تكليف',
          ),
        ],
      ),
    );
  }
}
