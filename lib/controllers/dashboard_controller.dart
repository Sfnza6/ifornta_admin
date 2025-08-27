import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Tabs: 0: شهر، 1: أسبوع، 2: يوم، 3: الكل
  final period = 3.obs;

  // إحصائيات مبدئية (تربط لاحقاً بالـ API)
  final stats = [
    ('إجمالي الإيرادات', '4'),
    ('عدد الأصناف', '27'),
    ('إجمالي الطلبات', '60'),
    ('إجمالي العملاء', '270'),
  ].obs;

  final mostOrdered = [
    (1, 'العيد الكبير', '268', '12-يول', 'https://i.imgur.com/4YQZQ2R.png'),
    (2, 'اسكندراني', '230', '14-يول', 'https://i.imgur.com/4YQZQ2R.png'),
    (3, 'بانوسي كبدة', '230', '17-يول', 'https://i.imgur.com/4YQZQ2R.png'),
  ].obs;

  final reviews = [
    ('عبدالرحيم خالد', 'منذ 1 يوم', 'نموذج تقييم، الأكل ممتاز والخدمة رائعة..'),
    ('محمد علي', 'منذ 2 أيام', 'الطعام جيد لكن الخدمة تحتاج تحسن..'),
  ].obs;
}
