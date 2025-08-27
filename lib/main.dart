import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iforenta_admin_2/core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';

void main() {
  runApp(const IforentaAdminApp());
}

class IforentaAdminApp extends StatelessWidget {
  const IforentaAdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Iforenta Admin',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
    );
  }
}
