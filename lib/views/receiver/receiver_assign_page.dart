import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/orders_controller.dart';
import 'package:iforenta_admin_2/controllers/drivers_controller.dart';

class ReceiverAssignPage extends StatelessWidget {
  const ReceiverAssignPage({super.key});

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    final ordersC = Get.find<OrdersController>();
    final driversC = Get.put(DriversController(), permanent: false);

    if (ordersC.orders.isEmpty && ordersC.loading.isFalse) {
      ordersC.fetch();
    }
    if (driversC.drivers.isEmpty && driversC.loading.isFalse) {
      driversC.fetchDrivers();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            alignment: Alignment.centerRight,
            child: const Text(
              'تكليف سائق بطلبية',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Obx(() {
              final pending = ordersC.orders
                  .where(
                    (o) => o.status == 'pending' || o.status == 'processing',
                  )
                  .toList();
              if (ordersC.loading.value && pending.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (pending.isEmpty) {
                return const Center(child: Text('لا توجد طلبات للتكليف'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                itemCount: pending.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = pending[i];
                  final amount = (o.total).toStringAsFixed(0);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'طلب #${o.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${o.customerName} • ${o.customerPhone}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${o.address}',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$amount د.ل',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final driverId = await _pickDriver(driversC);
                            if (driverId == null) return;
                            await driversC.assignOrderToDriver(
                              orderId: o.id,
                              driverId: driverId,
                            );
                          },
                          icon: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'تكليف',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<int?> _pickDriver(DriversController c) async {
    final id = await Get.dialog<int>(
      AlertDialog(
        title: const Text('اختر السائق'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            final list = c.drivers;
            if (c.loading.value)
              return const Center(child: CircularProgressIndicator());
            if (list.isEmpty) return const Text('لا توجد بيانات سائقين');
            return ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (_, i) {
                final d = list[i];
                return ListTile(
                  title: Text(d.$2), // name
                  subtitle: Text(d.$3), // phone
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Get.back(result: d.$1), // id
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ],
      ),
    );
    return id;
  }
}
