import 'dart:async';
import 'package:get/get.dart';
import 'package:iforenta_admin_2/data/models/dashboard_stats.dart';
import '../core/services/api_service.dart';
import '../core/config/env.dart';

class DashboardController extends GetxController {
  final _api = ApiService();

  // تبويب الفترات
  final period = 3.obs; // 0=يوم, 1=أسبوع, 2=شهر, 3=الكل (مثال)
  // بيانات الداشبورد
  final Rxn<DashboardStats> stats = Rxn<DashboardStats>();
  final loadingStats = false.obs;

  // الأكثر طلبًا: (الترتيب, الاسم, العدد, التاريخ, صورة)
  RxList<(int, String, String, String, String)> mostOrdered =
      <(int, String, String, String, String)>[].obs;

  // التقييمات: (الاسم, الوقت, النص)
  RxList<(String, String, String)> reviews = <(String, String, String)>[].obs;

  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    refreshAll(); // أول فتح

    // تحدّث تلقائي كل 60 ثانية
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      refreshAll();
    });

    // لما يتغير التبويب (الفترة) جدّد الأكثر طلبًا فقط
    ever<int>(period, (_) => fetchMostOrdered());
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  /// تحدّث كل أقسام الصفحة
  Future<void> refreshAll() async {
    await Future.wait([fetchStats(), fetchMostOrdered(), fetchReviews()]);
  }

  Future<void> fetchStats() async {
    try {
      loadingStats(true);
      final data = await _api.get(Env.stats);
      stats.value = DashboardStats.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : {},
      );
    } finally {
      loadingStats(false);
    }
  }

  Future<void> fetchMostOrdered() async {
    try {
      // ممكن تبعث الفترة للـ API إن كان يدعمها: Env.mostOrdered?period=${period.value}
      final data = await _api.get(Env.mostOrdered);
      mostOrdered.assignAll(
        (data as List).map(
          (e) => (
            int.tryParse('${e['rank'] ?? 1}') ?? 1,
            (e['name'] ?? '').toString(),
            '${e['count'] ?? 0}',
            (e['date'] ?? '').toString(),
            (e['image_url'] ?? e['image'] ?? '').toString(),
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> fetchReviews() async {
    try {
      final data = await _api.get(Env.reviews);
      reviews.assignAll(
        (data as List).map(
          (e) => (
            (e['name'] ?? '').toString(),
            (e['time'] ?? '').toString(),
            (e['text'] ?? '').toString(),
          ),
        ),
      );
    } catch (_) {}
  }
}
