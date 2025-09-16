import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/config/env.dart';
import '../data/models/offer_model.dart';

class OffersController extends GetxController {
  final _api = ApiService();

  // الحالة والبيانات
  final offers = <OfferModel>[].obs;
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  /* =================== جلب العروض =================== */
  Future<void> fetchOffers() async {
    try {
      loading(true);
      final data = await _api.get(Env.offersList);

      if (data is List) {
        offers.assignAll(
          data.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)),
        );
      } else if (data is Map && data['data'] is List) {
        offers.assignAll(
          (data['data'] as List).map(
            (e) => OfferModel.fromJson(e as Map<String, dynamic>),
          ),
        );
      } else {
        offers.clear();
      }
    } catch (e) {
      offers.clear();
      Get.snackbar(
        'خطأ',
        'تعذر جلب العروض: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading(false);
    }
  }

  /* =================== إضافة عرض =================== */
  Future<void> addOffer(OfferModel m) async {
    try {
      await _api.postForm(Env.offerAdd, {
        'title': m.title,
        'image_url': m.imageUrl,
        if (m.price != null) 'price': '${m.price}',
      });
      await fetchOffers();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر إضافة العرض: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /* =================== تعديل عرض =================== */
  Future<void> updateOffer(OfferModel m) async {
    try {
      await _api.postForm(Env.offerUpdate, {
        'id': '${m.id}',
        'title': m.title,
        'image_url': m.imageUrl,
        if (m.price != null) 'price': '${m.price}',
      });
      await fetchOffers();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر تعديل العرض: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /* =================== حذف عرض =================== */
  Future<void> deleteOffer(int id) async {
    try {
      await _api.postForm(Env.offerDelete, {'id': '$id'});
      offers.removeWhere((o) => o.id == id);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر حذف العرض: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
