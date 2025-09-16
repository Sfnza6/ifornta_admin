import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/orders_controller.dart';
import '../../data/models/order_model.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  static const brown = Color(0xFF6F3F17);
  static const pageBg = Color(0xFFF3F0ED);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OrdersController());
    final pad = MediaQuery.of(context).padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: brown,
          title: const Text('الطلبات', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: c.fetch,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            _SearchAndTabs(controller: c),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final list = c.filtered;
                if (c.loading.value && list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return const Center(child: Text('لا توجد طلبات'));
                }
                return RefreshIndicator(
                  onRefresh: c.fetch,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, pad.bottom + 12),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = list[i];
                      return _OrderCard(
                        order: o,
                        onAccept: () => c.updateStatus(o.id, 'processing'),
                        onCancel: () => c.updateStatus(o.id, 'cancelled'),
                        onDone: () => c.updateStatus(o.id, 'success'),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- شريط البحث + التبويبات -------------------- */

class _SearchAndTabs extends StatelessWidget {
  const _SearchAndTabs({required this.controller});
  final OrdersController controller;

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      'الكل',
      'قيد الانتظار',
      'قيد المعالجة',
      'ملغاة',
      'مكتملة',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: brown,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // بحث
          TextField(
            onChanged: (v) => controller.search.value = v,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم / الهاتف / رقم الطلب',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Tabs
          Obx(() {
            final sel = controller.filterIndex.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final active = i == sel;
                  return Padding(
                    padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 8),
                    child: ChoiceChip(
                      selected: active,
                      onSelected: (_) {
                        controller.filterIndex.value = i;
                        controller.fetch();
                      },
                      label: Text(tabs[i]),
                      selectedColor: Colors.white,
                      labelStyle: TextStyle(
                        color: active ? brown : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      backgroundColor: const Color(0xFF8E5A34),
                      side: BorderSide.none,
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/* -------------------- كارت الطلب -------------------- */

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onAccept,
    required this.onCancel,
    required this.onDone,
  });

  final OrderModel order;
  final VoidCallback onAccept, onCancel, onDone;

  static const brown = Color(0xFF6F3F17);

  Color _statusColor(String s) {
    return switch (s) {
      'pending' => Colors.orange,
      'processing' => Colors.blue,
      'cancelled' => Colors.red,
      'success' => Colors.green,
      _ => Colors.grey,
    };
  }

  String _statusText(String s) {
    return switch (s) {
      'pending' => 'قيد الانتظار',
      'processing' => 'قيد المعالجة',
      'cancelled' => 'ملغاة',
      'success' => 'مكتملة',
      _ => s,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // سطر علوي: رقم الطلب + حالة
          Row(
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: brown,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusText(order.status),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // معلومات العميل
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.customerName.isEmpty ? '—' : order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.phone_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(order.customerPhone),
            ],
          ),

          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.address,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                '${order.total.toStringAsFixed(2)} د.ل',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: brown,
                ),
              ),
              const Spacer(),
              if (order.createdAt != null)
                Text(
                  _prettyDate(order.createdAt!),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
            ],
          ),

          const SizedBox(height: 10),
          // أزرار الإجراءات
          Wrap(
            spacing: 10,
            children: [
              if (order.status == 'pending')
                _pillBtn(
                  icon: Icons.check_circle_outline,
                  label: 'قبول',
                  color: Colors.blue,
                  onTap: onAccept,
                ),
              if (order.status == 'pending' || order.status == 'processing')
                _pillBtn(
                  icon: Icons.cancel_outlined,
                  label: 'إلغاء',
                  color: Colors.red,
                  onTap: onCancel,
                ),
              if (order.status == 'processing')
                _pillBtn(
                  icon: Icons.done_all_outlined,
                  label: 'تم التسليم',
                  color: Colors.green,
                  onTap: onDone,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _prettyDate(DateTime dt) {
    // yyyy-mm-dd hh:mm
    two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  static Widget _pillBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
