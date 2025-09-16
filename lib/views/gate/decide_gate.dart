import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iforenta_admin_2/controllers/AuthController.dart';
import '../../core/routes/app_routes.dart';

class DecideGate extends StatefulWidget {
  const DecideGate({super.key});

  @override
  State<DecideGate> createState() => _DecideGateState();
}

class _DecideGateState extends State<DecideGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) {
        Get.offAllNamed(Routes.login);
        return;
      }
      final role = (auth.admin.value?.role ?? '').toLowerCase().trim();
      if (role == 'receiver') {
        Get.offAllNamed(Routes.receiverHome);
      } else {
        Get.offAllNamed(Routes.dashboard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
