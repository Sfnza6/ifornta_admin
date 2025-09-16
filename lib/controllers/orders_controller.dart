import 'dart:async';
import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/config/env.dart';
import '../data/models/order_model.dart';

class OrdersController extends GetxController {
  final _api = ApiService();

  // حالات الواجهة
  final loading = false.obs;
  final orders = <OrderModel>[].obs;

  /// 0 الكل - 1 pending - 2 processing - 3 cancelled - 4 success
  final filterIndex = 0.obs;

  /// نص البحث
  final search = ''.obs;

  Timer? _pollTimer;
  Worker? _filterWorker;
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();

    // أول تحميل
    fetch();

    // حدّث عند تغيير الفلتر
    _filterWorker = ever<int>(filterIndex, (_) => fetch());

    // بحث مع debounce لتخفيف الضغط
    _searchWorker = debounce<String>(search, (_) {
      // التصفية محليًا؛ إن أردت من السيرفر استبدل بسطر: fetch();
      orders.refresh();
    }, time: const Duration(milliseconds: 500));

    // تحديث تلقائي كل 10 ثواني
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => fetch(silent: true),
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _filterWorker?.dispose();
    _searchWorker?.dispose();
    super.onClose();
  }

  String? _statusByIndex(int i) {
    return switch (i) {
      0 => null, // all
      1 => 'pending',
      2 => 'processing',
      3 => 'cancelled',
      4 => 'success',
      _ => null,
    };
  }

  /// جلب الطلبات من السيرفر (متوافق مع المودل الجديد)
  Future<void> fetch({bool silent = false, String? status}) async {
    try {
      if (!silent) loading(true);
      final status = _statusByIndex(filterIndex.value);

      final data = await _api.get(
        Env.ordersList,
        query: {if (status != null) 'status': status},
      );

      if (data is List) {
        orders.assignAll(
          data.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e))),
        );
      } else if (data is Map && data['data'] is List) {
        orders.assignAll(
          (data['data'] as List).map(
            (e) => OrderModel.fromJson(Map<String, dynamic>.from(e)),
          ),
        );
      } else {
        orders.clear();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر جلب الطلبات: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!silent) loading(false);
    }
  }

  /// تغيير الفلتر من الواجهة
  void setFilter(int i) {
    if (i == filterIndex.value) return;
    filterIndex.value = i; // سيستدعي fetch عبر ever
  }

  /// تحديث نص البحث من الواجهة
  void setSearch(String q) {
    search.value = q;
  }

  /// تحديث حالة الطلب على السيرفر + مزامنة محلية (باستخدام copyWith من المودل)
  Future<void> updateStatus(int orderId, String status) async {
    try {
      await _api.postForm(Env.orderUpdate, {
        'order_id': '$orderId',
        'status': status,
      });

      final idx = orders.indexWhere((o) => _safeId(o) == orderId);
      if (idx != -1) {
        final updated = _copyWithStatus(orders[idx], status);
        orders[idx] = updated;
        orders.refresh();
      } else {
        // fallback لو القائمة تغيّرت
        await fetch(silent: true);
      }

      Get.snackbar(
        'تم',
        'تم تغيير حالة الطلب #$orderId إلى $status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر تحديث الحالة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// ناتج التصفية + البحث (محلي) — مرن مع أسماء الحقول
  List<OrderModel> get filtered {
    final q = search.value.trim();
    final st = _statusByIndex(filterIndex.value);

    return orders.where((o) {
      final okStatus = st == null ? true : _safeStatus(o) == st;

      final name = _safeName(o);
      final phone = _safePhone(o);
      final idStr = '${_safeId(o)}';

      final okSearch =
          q.isEmpty ||
          name.contains(q) ||
          phone.contains(q) ||
          idStr.contains(q);

      return okStatus && okSearch;
    }).toList();
  }

  /* ===================== أدوات توافق مع المودل الجديد ===================== */

  // نحاول قراءة الاسم من مفاتيح شائعة
  String _safeName(OrderModel o) {
    // إن كان المودل الجديد يوفّر getter/field مختلف، عدّل هنا المفتاح
    final map = o.toJson(); // يفترض المودل يوفّر toJson
    return (map['customer_name'] ?? map['customerName'] ?? map['name'] ?? '')
        .toString();
  }

  // نحاول قراءة الهاتف من مفاتيح شائعة
  String _safePhone(OrderModel o) {
    final map = o.toJson();
    return (map['phone'] ?? map['phone_number'] ?? map['mobile'] ?? '')
        .toString();
  }

  // قراءة المعرّف
  int _safeId(OrderModel o) {
    final map = o.toJson();
    final raw = (map['id'] ?? map['order_id'] ?? 0).toString();
    return int.tryParse(raw) ?? 0;
  }

  // قراءة الحالة
  String _safeStatus(OrderModel o) {
    final map = o.toJson();
    return (map['status'] ?? map['state'] ?? '').toString();
  }

  // إنشاء نسخة بالحالة الجديدة — مفضّل لو المودل يوفّر copyWith
  OrderModel _copyWithStatus(OrderModel o, String status) {
    try {
      // لو المودل يدعم copyWith({status}):
      // ignore: invalid_use_of_protected_member
      // سيعمل إن كان المودل يعرّف copyWith بهذه الصيغة
      // @ts-ignore (تعليق توضيحي فقط)
      return (o as dynamic).copyWith(status: status) as OrderModel;
    } catch (_) {
      // fallback: أعد البناء من json مع استبدال الحالة فقط
      final map = Map<String, dynamic>.from(o.toJson());
      map['status'] = status;
      return OrderModel.fromJson(map);
    }
  }
}
