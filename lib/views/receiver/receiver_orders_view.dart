import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/orders_controller.dart';

class ReceiverOrdersPage extends StatelessWidget {
  const ReceiverOrdersPage({super.key});

  static const brown = Color(0xFF6F3F17);
  static const pageBg = Color(0xFFF3F0ED);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrdersController>();

    // أول تحميل
    if (c.orders.isEmpty && c.loading.isFalse) {
      c.fetch();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // هيدر بإجمالي الطلبات
          _HeaderTotal(),

          // شريط فلترة سريع
          _FilterChips(controller: c),

          const SizedBox(height: 8),

          // قائمة الطلبات
          Expanded(
            child: Obx(() {
              final list = c.filtered;
              if (c.loading.value && list.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return const Center(child: Text('لا توجد طلبات'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final o = list[i];
                  final isDelivery = (o.address).trim().isNotEmpty;
                  final type = isDelivery ? 'توصيل' : 'استلام';
                  final amount = (o.total).toStringAsFixed(0);

                  return _OrderRow(
                    name: o.customerName,
                    phone: o.customerPhone,
                    amount: amount,
                    type: type,
                    onTap: () {},
                    onAccept: () => c.updateStatus(o.id, 'processing'),
                    onDone: () => c.updateStatus(o.id, 'success'),
                    onCancel: () => c.updateStatus(o.id, 'cancelled'),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HeaderTotal extends StatelessWidget {
  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrdersController>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Obx(() {
            final total = c.orders.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: brown,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          }),
          const Spacer(),
          const Text(
            'إجمالي الطلبات',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});
  final OrdersController controller;
  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.filterIndex.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Row(
          children: [
            _chip('الكل', 0, idx, controller),
            _chip('قيد الانتظار', 1, idx, controller),
            _chip('قيد التنفيذ', 2, idx, controller),
            _chip('ملغاة', 3, idx, controller),
            _chip('مكتملة', 4, idx, controller),
            IconButton(
              onPressed: controller.fetch,
              icon: const Icon(Icons.refresh),
              color: brown,
              tooltip: 'تحديث',
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(String label, int i, int current, OrdersController c) {
    final selected = current == i;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Colors.black87),
        ),
        selected: selected,
        selectedColor: brown,
        backgroundColor: const Color(0xFFF2EFEA),
        onSelected: (_) {
          c.filterIndex.value = i;
          c.fetch();
        },
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.name,
    required this.phone,
    required this.amount,
    required this.type,
    this.onTap,
    this.onAccept,
    this.onDone,
    this.onCancel,
  });

  final String name, phone, amount, type;
  final VoidCallback? onTap, onAccept, onDone, onCancel;
  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        child: Column(
          children: [
            Row(
              children: [
                // نوع الطلب يسار
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // المبلغ
                Text(
                  '$amount د.ل',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 14),
                // الاسم + الهاتف
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/avatar_fallback.png'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _actionBtn(Icons.check_circle, 'قبول', onAccept),
                const SizedBox(width: 8),
                _actionBtn(Icons.done_all, 'تم', onDone),
                const SizedBox(width: 8),
                _actionBtn(Icons.cancel, 'إلغاء', onCancel, danger: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool danger = false,
  }) {
    final color = danger ? Colors.red : brown;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
