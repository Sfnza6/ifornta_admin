import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/services/api_service.dart';
import '../core/config/env.dart';

class AdminUser {
  final int id;
  final String name;
  final String phone;
  final String role; // admin | receiver | ...
  final String avatarUrl;

  const AdminUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.avatarUrl,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    int i(v) => int.tryParse('${v ?? 0}') ?? 0;
    String s(v) => (v ?? '').toString();
    return AdminUser(
      id: i(j['id']),
      name: s(j['name']),
      phone: s(j['phone']),
      role: s(j['role']),
      avatarUrl: s(j['avatar_url'] ?? j['image_url'] ?? j['photo']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'avatar_url': avatarUrl,
  };
}

class AuthController extends GetxController {
  final _api = ApiService();
  final _box = GetStorage('auth');

  final Rxn<AdminUser> admin = Rxn<AdminUser>();
  final isBusy = false.obs;

  static const _kToken = 'token';
  static const _kUser = 'user';

  String? get token => _box.read<String?>(_kToken);
  bool get isLoggedIn => admin.value != null;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final t = _box.read<String?>(_kToken);
    final u = _box.read<String?>(_kUser);
    if (t != null && u != null) {
      try {
        admin.value = AdminUser.fromJson(jsonDecode(u));
      } catch (_) {
        await _box.remove(_kToken);
        await _box.remove(_kUser);
        admin.value = null;
      }
    }
  }

  Map<String, dynamic>? _extractUserMap(dynamic res) {
    if (res is Map) {
      if (res['admin'] is Map) return Map<String, dynamic>.from(res['admin']);
      if (res['user'] is Map) return Map<String, dynamic>.from(res['user']);
      if (res['data'] is Map) return Map<String, dynamic>.from(res['data']);
      if (res.containsKey('id')) return Map<String, dynamic>.from(res);
    }
    return null;
  }

  String? _extractToken(dynamic res) {
    if (res is Map) {
      final t = res['token'] ?? res['access_token'];
      if (t != null) return t.toString();
    }
    return null;
  }

  Future<bool> login({required String phone, required String password}) async {
    try {
      isBusy(true);
      final res = await _api.postForm(Env.loginAdmin, {
        'phone': phone,
        'password': password,
      });

      if (res is Map && (res['status'] == 'success' || res['ok'] == true)) {
        final userMap = _extractUserMap(res);
        final t = _extractToken(res);
        if (userMap == null) {
          Get.snackbar('خطأ', 'استجابة غير متوقعة من الخادم');
          return false;
        }
        final user = AdminUser.fromJson(userMap);
        admin.value = user;
        if (t != null) await _box.write(_kToken, t);
        await _box.write(_kUser, jsonEncode(user.toJson()));
        return true;
      }

      Get.snackbar(
        'خطأ',
        (res is Map
                ? (res['message'] ?? 'بيانات الدخول غير صحيحة')
                : 'بيانات الدخول غير صحيحة')
            .toString(),
      );
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر الاتصال: $e');
      return false;
    } finally {
      isBusy(false);
    }
  }

  Future<void> logout() async {
    await _box.remove(_kToken);
    await _box.remove(_kUser);
    admin.value = null;
  }
}
