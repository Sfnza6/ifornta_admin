import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/items_controller.dart';

class ReceiverItemsPage extends StatelessWidget {
  const ReceiverItemsPage({super.key});

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ItemsController>();
    if (c.items.isEmpty && c.loading.isFalse) {
      c.fetchItems();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            alignment: Alignment.centerRight,
            child: const Text(
              'إدارة تفعيل/إيقاف الأصناف',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = c.items.toList();
              if (c.loading.value && list.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return const Center(child: Text('لا توجد أصناف'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final it = list[i];
                  // اعتبر أن "الخصم" null = مفعّل (مثال فقط). عدّل حسب سكربتك (is_active).
                  final enabled = (it.discount == null);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                          child: Text(
                            it.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Switch(
                          value: enabled,
                          activeColor: brown,
                          onChanged: (v) async {
                            // استبدل بنداء API حقيقي للتفعيل/الإيقاف
                            // مثال:
                            // await _api.postForm(Env.itemToggle, {'id': it.id, 'active': v ? '1' : '0'});
                            // ثم جلب
                            Get.snackbar(
                              'تنبيه',
                              v ? 'تم تفعيل ${it.name}' : 'تم إيقاف ${it.name}',
                            );
                          },
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
}
