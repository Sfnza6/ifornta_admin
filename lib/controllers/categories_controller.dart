import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/api_service.dart';
import '../core/config/env.dart';

import '../data/models/category_model.dart';
import '../data/models/item_model.dart';

class CategoriesController extends GetxController {
  final _api = ApiService();

  // حالة التحميل والحفظ والبحث
  final loading = false.obs;
  final saving = false.obs;
  final searchCtrl = TextEditingController();

  // البيانات
  final categories = <CategoryModel>[].obs;
  final filtered = <CategoryModel>[].obs;

  // عدّاد الأصناف لكل قسم
  final itemCountByCatId = <int, int>{}.obs;

  // نموذج (اسم وصورة)
  final nameCtrl = TextEditingController();
  final imagePath = ''.obs; // معاينة محلية
  File? imageFile;
  final currentImageUrl = ''.obs; // رابط الشبكة (للتعديل)

  // لالتقاط الصور
  final _picker = ImagePicker();

  // لو احتجت تطبيع روابط localhost إلى IP الشبكة
  static const String kBaseUrl = 'http://192.168.1.129/iforenta_api';
  static String normalizeImageUrl(String? raw) {
    var u = (raw ?? '').trim();
    if (u.isEmpty) return '';
    u = u.replaceAll(
      RegExp(
        r'^https?://(localhost|127\.0\.0\.1)(:\d+)?',
        caseSensitive: false,
      ),
      kBaseUrl,
    );
    if (u.startsWith('/')) return '$kBaseUrl$u'.replaceAll(' ', '%20');
    final isFilename = !u.startsWith('http') && !u.startsWith('/');
    if (isFilename) {
      if (!u.toLowerCase().contains('uploads/')) {
        return '$kBaseUrl/uploads/$u'.replaceAll(' ', '%20');
      }
      return '$kBaseUrl/$u'.replaceAll(' ', '%20');
    }
    return u.replaceAll(' ', '%20');
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    searchCtrl.addListener(_reapplyFilter);
    ever<List<CategoryModel>>(categories, (_) => _reapplyFilter());
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    nameCtrl.dispose();
    super.onClose();
  }

  /* =================== جلب الأقسام + الأصناف (للعدّادات) =================== */
  Future<void> fetchAll() async {
    try {
      loading(true);

      // الأقسام
      final resCats = await _api.get(Env.categoriesList);
      List<CategoryModel> listCats = [];
      if (resCats is Map && resCats['status'] == 'success') {
        listCats = (resCats['data'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (resCats is List) {
        listCats = resCats
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      categories.assignAll(listCats);

      // الأصناف لحساب عدد كل قسم
      final resItems = await _api.get(Env.itemsList);
      List<ItemModel> listItems = [];
      if (resItems is Map && resItems['status'] == 'success') {
        listItems = (resItems['data'] as List)
            .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (resItems is List) {
        listItems = resItems
            .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final map = <int, int>{};
      for (final it in listItems) {
        final cid = it.categoryId ?? -1;
        if (cid <= 0) continue;
        map[cid] = (map[cid] ?? 0) + 1;
      }
      itemCountByCatId.assignAll(map);

      _reapplyFilter();
    } catch (e) {
      categories.clear();
      filtered.clear();
      itemCountByCatId.clear();
      Get.snackbar(
        'خطأ',
        'تعذر جلب الأقسام/الأصناف: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading(false);
    }
  }

  /* =================== فلترة =================== */
  void _reapplyFilter() {
    final q = searchCtrl.text.trim();
    if (q.isEmpty) {
      filtered.assignAll(categories);
    } else {
      filtered.assignAll(categories.where((c) => c.name.contains(q)));
    }
  }

  /* =================== عدد أصناف القسم =================== */
  int countItemsInCategory(int categoryId) => itemCountByCatId[categoryId] ?? 0;

  /* =================== اختيار صورة =================== */
  Future<void> pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) {
      imageFile = File(picked.path);
      imagePath.value = picked.path;
    }
  }

  /* =================== رفع صورة (إن وجدت) =================== */
  Future<String?> _uploadImageIfNeeded() async {
    if (imageFile == null) {
      return currentImageUrl.value.isNotEmpty ? currentImageUrl.value : null;
    }
    try {
      final res = await _api.uploadFile(
        Env.uploadImage,
        filePath: imageFile!.path,
        fieldName: 'image',
      );

      if (res is Map && (res['status'] == 'success' || res['ok'] == true)) {
        final u = res['url'] ?? res['data']?['url'];
        if (u != null) return u.toString();
      } else if (res is String) {
        final decoded = jsonDecode(res);
        if (decoded is Map &&
            (decoded['status'] == 'success' || decoded['ok'] == true)) {
          final u = decoded['url'] ?? decoded['data']?['url'];
          if (u != null) return u.toString();
        }
      }
      Get.snackbar(
        'خطأ',
        'فشل رفع الصورة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل رفع الصورة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /* =================== إضافة قسم =================== */
  Future<bool> saveNewCategory() async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'أدخل اسم القسم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      saving(true);

      String imgUrl = '';
      final uploaded = await _uploadImageIfNeeded();
      if (uploaded != null) imgUrl = uploaded;

      final body = {
        'name': nameCtrl.text.trim(),
        'image_url': imgUrl, // يخزن كرابط كامل
        'active': '1',
      };

      final res = await _api.postForm(Env.categoryAdd, body);

      if (res is Map && res['status'] == 'success') {
        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          final newCat = CategoryModel.fromJson(
            res['data'] as Map<String, dynamic>,
          );
          categories.insert(0, newCat);
        } else {
          await fetchAll();
        }
        resetForm();
        return true;
      } else {
        final msg = (res is Map ? res['message'] : null) ?? 'فشل إضافة القسم';
        Get.snackbar(
          'خطأ',
          msg.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل الاتصال: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      saving(false);
    }
  }

  /* =================== تعديل قسم =================== */
  void editCategory(CategoryModel c) {
    // حضّر النموذج
    nameCtrl.text = c.name;
    imagePath.value = '';
    imageFile = null;
    currentImageUrl.value = c.image;
    // افتح الشيت
    showCategorySheet(title: 'تعديل قسم', onSubmit: () => updateCategory(c.id));
  }

  Future<bool> updateCategory(int id) async {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'أدخل اسم القسم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      saving(true);

      String imgUrl = currentImageUrl.value;
      final uploaded = await _uploadImageIfNeeded();
      if (uploaded != null) imgUrl = uploaded;

      final body = {
        'id': '$id',
        'name': nameCtrl.text.trim(),
        'image_url': imgUrl,
        'active': '1',
      };

      final res = await _api.postForm(Env.categoryUpdate, body);

      if (res is Map && res['status'] == 'success') {
        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          final updated = CategoryModel.fromJson(
            res['data'] as Map<String, dynamic>,
          );
          final idx = categories.indexWhere((e) => e.id == updated.id);
          if (idx != -1) {
            categories[idx] = updated;
            categories.refresh();
          } else {
            await fetchAll();
          }
        } else {
          await fetchAll();
        }
        resetForm();
        return true;
      } else {
        final msg = (res is Map ? res['message'] : null) ?? 'فشل التعديل';
        Get.snackbar(
          'خطأ',
          msg.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل الاتصال: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      saving(false);
    }
  }

  /* =================== حذف قسم =================== */
  void confirmDeleteCategory(CategoryModel c) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      middleText: 'هل تريد حذف "${c.name}" ؟',
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await _deleteCategory(c);
      },
    );
  }

  Future<void> _deleteCategory(CategoryModel c) async {
    try {
      final res = await _api.postForm(Env.categoryDelete, {
        'id': c.id.toString(),
      });

      final ok =
          (res is Map && res['status'] == 'success') ||
          (res is String && res.contains('"status":"success"'));

      if (ok) {
        categories.removeWhere((e) => e.id == c.id);
        filtered.removeWhere((e) => e.id == c.id);
        Get.snackbar(
          'تم',
          'تم حذف ${c.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final msg =
            (res is Map ? res['message'] : res)?.toString() ?? 'فشل الحذف';
        Get.snackbar('خطأ', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر الاتصال: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /* =================== شيت الإضافة/التعديل =================== */
  void showAddCategorySheet() {
    resetForm();
    showCategorySheet(title: 'إضافة قسم جديد', onSubmit: saveNewCategory);
  }

  void showCategorySheet({
    required String title,
    required Future<bool> Function() onSubmit,
  }) {
    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F3F17),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: _fieldDecoration('اسم القسم'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: pickImageFromGallery,
                  child: Obx(() {
                    Widget child;
                    if (imagePath.value.isNotEmpty && imageFile != null) {
                      child = Image.file(
                        imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    } else if (currentImageUrl.value.isNotEmpty) {
                      child = Image.network(
                        currentImageUrl.value,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    } else {
                      child = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 36,
                            color: Color(0xFFB88969),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'اختر صورة من المعرض',
                            style: TextStyle(color: Color(0xFFB88969)),
                          ),
                        ],
                      );
                    }
                    return Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EFEA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      child: child,
                    );
                  }),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F3F17),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: saving.value
                          ? null
                          : () async {
                              final ok = await onSubmit();
                              if (ok && Get.isOverlaysOpen) Get.back();
                            },
                      child: saving.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'حفظ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  /* =================== تنظيف =================== */
  void resetForm() {
    nameCtrl.clear();
    imagePath.value = '';
    imageFile = null;
    currentImageUrl.value = '';
  }
}

/* أدوات الحقول */
InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF2EFEA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),
  );
}
