import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iforenta_admin_2/views/widgets/bottom_nav.dart';
import 'package:iforenta_admin_2/views/widgets/header_bar.dart';
import 'package:iforenta_admin_2/views/widgets/most_ordered_list.dart';
import 'package:iforenta_admin_2/views/widgets/reviews_carousel.dart';
import 'package:iforenta_admin_2/views/widgets/side_overlay_menu.dart';
import 'package:iforenta_admin_2/views/widgets/stat_card.dart';

import '../../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

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
              const SizedBox(height: 12),

              // إحصائيات
              Obx(() {
                // اقرأ RxList مباشرة داخل الـbuilder
                final cardWidth =
                    (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
                final stats = controller.stats; // RxList
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(stats.length, (i) {
                    final s = stats[i];
                    return SizedBox(
                      width: cardWidth,
                      child: StatCard(title: s.$1, value: s.$2),
                    );
                  }),
                );
              }),

              const SizedBox(height: 16),

              // الأكثر طلباً
              Obx(() {
                final p = controller.period.value; // RxInt
                final items = controller.mostOrdered.toList(); // RxList -> List
                return MostOrderedList(
                  period: p,
                  onChange: (i) => controller.period.value = i,
                  items: items,
                );
              }),

              const SizedBox(height: 16),

              // التقييمات
              Obx(() {
                final reviews = controller.reviews.toList(); // RxList -> List
                return ReviewsCarousel(reviews: reviews);
              }),
            ],
          ),
        ),

        // الشريط السفلي
        bottomNavigationBar: BottomNav(
          currentIndex: 0, // ← أنت الآن في لوحة التحكم
          onOpenMenu: (ctx) => showSideOverlayMenu(ctx),
          onMiddle: () {}, // اختياري
        ),
      ),
    );
  }
}
