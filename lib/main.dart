import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iforenta_admin_2/controllers/AuthController.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('auth'); // تخزين الجلسة
  Get.put(AuthController(), permanent: true); // AuthController متاح للجميع
  runApp(const IforentaAdminApp(initialRoute: ''));
}

class IforentaAdminApp extends StatelessWidget {
  const IforentaAdminApp({super.key, required String initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Iforenta Admin',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.decide, // ⬅️ بوابة التوجيه حسب الجلسة/الدور
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
    );
  }
}
