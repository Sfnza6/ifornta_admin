import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/api_service.dart';
import '../core/config/env.dart';

import '../data/models/item_model.dart';
import '../data/models/category_model.dart';

class ItemsController extends GetxController {
  final _api = ApiService();

  // حالات
  final loading = false.obs;
  final saving = false.obs;

  // بيانات الأصناف
  final items = <ItemModel>[].obs;
  final filtered = <ItemModel>[].obs;

  // البحث
  final searchCtrl = TextEditingController();

  // حقول النموذج
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final discountCtrl = TextEditingController();

  // الأقسام
  final categories = <CategoryModel>[].obs;
  final selectedCategoryId = Rxn<int>();

  // الصورة المختارة من المعرض
  final imagePath = ''.obs; // مسار محلي لعرض المعاينة
  File? imageFile;
  final currentImageUrl = ''.obs; // صورة الشبكة الحالية عند التعديل

  final _picker = ImagePicker();

  // ===== Helpers للتعامل مع ردود API غير نظيفة =====
  bool _isSuccess(dynamic res) {
    try {
      if (res is Map) return res['status'] == 'success' || res['ok'] == true;
      if (res is String) {
        final m = jsonDecode(res);
        if (m is Map) return m['status'] == 'success' || m['ok'] == true;
        return res.contains('"status"') && res.contains('"success"');
      }
    } catch (_) {
      /* ignore */
    }
    return false;
  }

  Map<String, dynamic>? _dataMap(dynamic res) {
    try {
      if (res is Map) {
        return (res['data'] is Map)
            ? (res['data'] as Map).cast<String, dynamic>()
            : null;
      }
      if (res is String) {
        final m = jsonDecode(res);
        if (m is Map && m['data'] is Map) {
          return (m['data'] as Map).cast<String, dynamic>();
        }
      }
    } catch (_) {
      /* ignore */
    }
    return null;
  }

  String _errorMessage(dynamic res, String fallback) {
    try {
      if (res is Map && res['message'] != null) {
        return res['message'].toString();
      }
      if (res is String) {
        final m = jsonDecode(res);
        if (m is Map && m['message'] != null) return m['message'].toString();
      }
    } catch (_) {
      /* ignore */
    }
    return fallback;
  }

  @override
  void onInit() {
    super.onInit();
    fetchItems();
    fetchCategories();

    // أي تغيير في items ينعكس مباشرة على filtered مع الحفاظ على نص البحث الحالي
    ever<List<ItemModel>>(items, (_) => _reapplyFilter());

    // تطبيق الفلترة عند تغيير نص البحث
    searchCtrl.addListener(() => _reapplyFilter());
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
    super.onClose();
  }

  /* =================== جلب الأقسام =================== */
  Future<void> fetchCategories() async {
    try {
      final res = await _api.get(Env.categoriesList);
      if (_isSuccess(res)) {
        final list =
            (res is Map ? res['data'] : (jsonDecode(res as String)['data']))
                as List;
        categories.assignAll(
          list
              .map(
                (e) =>
                    CategoryModel.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList(),
        );
      } else if (res is List) {
        categories.assignAll(
          res
              .map(
                (e) =>
                    CategoryModel.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        categories.clear();
      }
    } catch (e) {
      categories.clear();
      Get.snackbar(
        'خطأ',
        'تعذر جلب الأقسام: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /* =================== جلب الأصناف =================== */
  Future<void> fetchItems() async {
    try {
      loading(true);
      final res = await _api.get(Env.itemsList);

      if (_isSuccess(res)) {
        final list =
            (res is Map ? res['data'] : (jsonDecode(res as String)['data']))
                as List;
        items.assignAll(
          list
              .map(
                (e) => ItemModel.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList(),
        );
      } else if (res is List) {
        items.assignAll(
          res
              .map(
                (e) => ItemModel.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList(),
        );
      } else {
        items.clear();
      }
      _reapplyFilter();
    } catch (e) {
      items.clear();
      filtered.clear();
      Get.snackbar(
        'خطأ',
        'تعذر جلب الأصناف: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading(false);
    }
  }

  /* =================== فلترة البحث =================== */
  void _reapplyFilter() {
    final q = searchCtrl.text.trim();
    if (q.isEmpty) {
      filtered.assignAll(items);
    } else {
      filtered.assignAll(
        items.where(
          (e) =>
              (e.name).toString().contains(q) ||
              (e.description).toString().contains(q),
        ),
      );
    }
  }

  void onSearchChanged(String q) => _reapplyFilter();

  /* ========= الصورة من المعرض + رفع للسيرفر ========= */
  Future<void> pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) {
      imageFile = File(picked.path);
      imagePath.value = picked.path; // معاينة محلية
    }
  }

  // يرفع الصورة، ويرجع رابط URL النهائي من السيرفر
  Future<String?> _uploadImageIfNeeded() async {
    if (imageFile == null) return null;
    try {
      final res = await _api.uploadFile(
        Env.uploadImage,
        filePath: imageFile!.path,
        fieldName: 'image', // مهم: يتوافق مع PHP $_FILES['image']
        // extraFields: {'folder': 'items'}, // فعّلها فقط لو سكربت PHP يدعمها
      );

      if (_isSuccess(res)) {
        final map = (res is Map) ? res : jsonDecode(res as String) as Map;
        final u =
            map['url'] ?? (map['data'] is Map ? (map['data']['url']) : null);
        if (u != null) return u.toString();
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

  /* =================== إضافة صنف =================== */
  Future<bool> saveNewItem() async {
    if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'أدخل الاسم والسعر',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (selectedCategoryId.value == null) {
      Get.snackbar('تنبيه', 'اختر قسماً', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    try {
      saving(true);

      String imgUrl = '';
      final uploaded = await _uploadImageIfNeeded();
      if (uploaded != null) imgUrl = uploaded;

      final body = {
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'price': priceCtrl.text.trim(),
        'discount': discountCtrl.text.trim(), // اختياري
        'category_id': selectedCategoryId.value.toString(),
        'image_url': imgUrl, // خزّن الرابط في الـDB
      };

      final res = await _api.postForm(Env.itemAdd, body);

      if (_isSuccess(res)) {
        final data = _dataMap(res);
        if (data != null) {
          final newItem = ItemModel.fromJson(data);
          items.insert(0, newItem); // تحديث فوري
        } else {
          await fetchItems(); // fallback
        }
        resetForm();
        return true;
      } else {
        Get.snackbar(
          'خطأ',
          _errorMessage(res, 'فشل في الحفظ'),
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

  /* =================== تأكيد وحذف صنف =================== */
  void confirmDelete(ItemModel it) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      middleText: 'هل تريد حذف "${it.name}" ؟',
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await deleteItem(it);
      },
    );
  }

  Future<void> deleteItem(ItemModel it) async {
    // حذف تفاؤلي مع إمكانية التراجع عند الفشل
    final idx = items.indexWhere((e) => e.id == it.id);
    if (idx == -1) return;
    final removed = items.removeAt(idx);

    try {
      final res = await _api.postForm(Env.itemDelete, {'id': it.id.toString()});
      if (_isSuccess(res)) {
        Get.snackbar(
          'تم',
          'تم حذف ${it.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // ارجاع العنصر لو فشل الخادم
        items.insert(idx, removed);
        Get.snackbar(
          'خطأ',
          _errorMessage(res, 'فشل الحذف'),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // ارجاع العنصر عند الاستثناء
      items.insert(idx, removed);
      Get.snackbar(
        'خطأ',
        'تعذر الاتصال: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /* =================== تعديل صنف =================== */
  Future<bool> updateItem(int id) async {
    if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'أدخل الاسم والسعر',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      saving(true);

      // لو اخترنا صورة جديدة نرفعها، وإلا نستخدم رابط الشبكة الحالي
      String imgUrl = currentImageUrl.value;
      final uploaded = await _uploadImageIfNeeded();
      if (uploaded != null) imgUrl = uploaded;

      final body = {
        'id': id.toString(),
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'price': priceCtrl.text.trim(),
        'discount': discountCtrl.text.trim(),
        'category_id': selectedCategoryId.value?.toString() ?? '',
        'image_url': imgUrl, // لو فاضي: سكربت الـPHP يبقي القديمة
      };

      final res = await _api.postForm(Env.itemUpdate, body);

      if (_isSuccess(res)) {
        final data = _dataMap(res);
        if (data != null) {
          final updated = ItemModel.fromJson(data);
          final idx = items.indexWhere((e) => e.id == updated.id);
          if (idx != -1) {
            items[idx] = updated;
            items.refresh(); // إشعار فوري لـ Obx
          } else {
            await fetchItems();
          }
        } else {
          await fetchItems();
        }
        resetForm();
        return true;
      } else {
        Get.snackbar(
          'خطأ',
          _errorMessage(res, 'فشل التعديل'),
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

  /* =================== تجهيز نموذج التعديل =================== */
  void prepareEdit(ItemModel it) {
    nameCtrl.text = it.name;
    descCtrl.text = it.description;
    priceCtrl.text = it.price.toString();
    discountCtrl.clear(); // أو عيّن قيمة الخصم لو عندك
    selectedCategoryId.value = it.categoryId;
    imageFile = null;
    currentImageUrl.value = it.image; // رابط الشبكة الحالي
    imagePath.value = '';
  }

  /* =================== تنظيف =================== */
  void resetForm() {
    nameCtrl.clear();
    descCtrl.clear();
    priceCtrl.clear();
    discountCtrl.clear();
    selectedCategoryId.value = null;
    imagePath.value = '';
    imageFile = null;
    // لا تلمس currentImageUrl هنا حتى لا تفقد صورة العنصر في وضع التعديل إلا بعد نجاح العملية
  }

  /* =================== عرض مختصر =================== */
  void viewItem(ItemModel it) {
    Get.snackbar('معاينة', it.name, snackPosition: SnackPosition.BOTTOM);
  }
}
