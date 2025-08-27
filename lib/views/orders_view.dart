import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iforenta_admin_2/data/models/order_model.dart';
import 'package:iforenta_admin_2/views/widgets/bottom_nav.dart';
import 'package:iforenta_admin_2/views/widgets/header_bar.dart';
import 'package:iforenta_admin_2/views/widgets/side_overlay_menu.dart';
import '../../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, pad.bottom + 16),
            children: [
              const HeaderBar(),
              const SizedBox(height: 10),
              _SearchBar(onQuery: (q) => controller.search.value = q),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _Filters(current: controller.filterIndex)),
                  const SizedBox(width: 6),
                  const Text(
                    'الطلبات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() => _OrdersList(orders: controller.filtered)),
            ],
          ),
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: 2, // أو 1 حسب ما تحب تبرز
          onOpenMenu: (ctx) => showSideOverlayMenu(ctx),
          onMiddle: () {}, // لو تبي تتصرف في زر الوسط
        ),
      ),
    );
  }
}

/* -------- Widgets داخل نفس الملف لتبسيط النسخة (يمكن نقلها لاحقاً لـ common/widgets) -------- */

class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onQuery;
  const _SearchBar({required this.onQuery});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF6F3F17);
    return Container(
      decoration: const BoxDecoration(
        color: brown,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          _circle(brown, Icons.tune, () {}),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _c,
                      onChanged: widget.onQuery,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _circle(brown, Icons.chevron_right, () {}),
        ],
      ),
    );
  }

  Widget _circle(Color c, IconData i, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(28),
    child: Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(i, color: c),
    ),
  );
}

class _Filters extends StatelessWidget {
  final RxInt current;
  const _Filters({required this.current});
  @override
  Widget build(BuildContext context) {
    final labels = ['الكل', 'قيد التقديم', 'تحت التجهيز', 'فشلت'];
    return Obx(
      () => Wrap(
        spacing: 6,
        children: List.generate(labels.length, (i) {
          final sel = i == current.value;
          return GestureDetector(
            onTap: () => current.value = i,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF6F3F17) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1D8CF)),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: sel ? Colors.white : const Color(0xFF6F3F17),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _box(),
      child: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
          ...orders.map((o) => _row(o)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _row(OrderModel o) {
    Color stripe = switch (o.status) {
      'success' => const Color(0xFF2FB65D),
      'cancelled' => const Color(0xFFE64A45),
      'pending' => const Color(0xFFD4902B),
      'processing' => const Color(0xFF6F3F17),
      _ => const Color(0xFFD4902B),
    };
    return Stack(
      children: [
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // يمين: رقم الطلب + الاسم + الهاتف
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            const TextSpan(text: 'الاسم '),
                            TextSpan(text: '#${o.id}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        o.phone,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  // يسار: السعر + نوع الطلب
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${o.total.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 2),
                          const Text('د .'),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        o.type,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Divider(height: 8),
            ),
          ],
        ),
        PositionedDirectional(
          end: 0,
          top: 10,
          bottom: 10,
          child: Container(
            width: 6,
            decoration: BoxDecoration(
              color: stripe,
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(4),
                bottomStart: Radius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.12),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
