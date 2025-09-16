import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';

const _brown = Color(0xFF6F3F17);

Future<void> showSideOverlayMenu(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierLabel: "menu",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0), // يبدأ من اليمين
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

      return SlideTransition(
        position: offset,
        child: Align(
          alignment: Alignment.centerRight,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(ctx).size.width * 0.75,
                height: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      children: [
                        const SizedBox(height: 50),

                        // الطلبات
                        _MenuItem(
                          title: 'الطلبات',
                          icon: Icons.receipt_long_outlined,
                          onTap: () async {
                            Get.back();
                            await Future.delayed(
                              const Duration(milliseconds: 80),
                            );
                            Get.toNamed(Routes.orders);
                          },
                        ),
                        const SizedBox(height: 4),

                        // قائمة الطعام (منسدلة)
                        const _FoodMenuExpansion(),

                        const SizedBox(height: 4),

                        // الزبائن (مثال — ضيف له route لاحقًا)
                      ],
                    ),

                    // زر إغلاق دائري أعلى اليسار
                    Positioned(
                      top: 14,
                      left: 12,
                      child: InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: _brown,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/* --------------------------- Widgets داخلية --------------------------- */

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _brown),
      trailing: const Icon(Icons.chevron_left, color: _brown),
      title: Text(
        title,
        style: const TextStyle(
          color: _brown,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FoodMenuExpansion extends StatefulWidget {
  const _FoodMenuExpansion();

  @override
  State<_FoodMenuExpansion> createState() => _FoodMenuExpansionState();
}

class _FoodMenuExpansionState extends State<_FoodMenuExpansion> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () => setState(() => _open = !_open),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restaurant_menu, color: _brown),
          trailing: Icon(
            _open ? Icons.expand_less : Icons.expand_more,
            color: _brown,
          ),
          title: const Text(
            'قائمة الطعام',
            style: TextStyle(
              color: _brown,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
            child: Column(
              children: [
                // الأصناف
                _SubItem(
                  title: 'الأصناف',
                  icon: Icons.lunch_dining_outlined,
                  onTap: () async {
                    Get.back();
                    await Future.delayed(const Duration(milliseconds: 80));
                    Get.toNamed(Routes.items);
                  },
                ),
                // ✅ الأقسام
                _SubItem(
                  title: 'الأقسام',
                  icon: Icons.folder_open_outlined,
                  onTap: () async {
                    Get.back();
                    await Future.delayed(const Duration(milliseconds: 80));
                    Get.toNamed(Routes.categories);
                  },
                ),
                // العروض
                _SubItem(
                  title: 'العروض',
                  icon: Icons.local_offer_outlined,
                  onTap: () async {
                    Get.back();
                    await Future.delayed(const Duration(milliseconds: 80));
                    Get.toNamed(Routes.offers);
                  },
                ),
              ],
            ),
          ),
          crossFadeState: _open
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}

class _SubItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _SubItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 0),
      leading: Icon(icon, color: _brown),
      title: Text(
        title,
        style: const TextStyle(color: _brown, fontWeight: FontWeight.w700),
      ),
    );
  }
}
