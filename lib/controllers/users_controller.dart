import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/config/env.dart';
import '../data/models/user_model.dart';

class UsersController extends GetxController {
  final _api = ApiService();
  final loading = false.obs;
  final users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      loading(true);
      final data = await _api.get(Env.usersList); // يرجع List
      final list = (data as List).map((e) => UserModel.fromJson(e)).toList();
      users.assignAll(list);
    } finally {
      loading(false);
    }
  }
}
