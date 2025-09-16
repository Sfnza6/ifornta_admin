import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import '../../data/models/user_model.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: brown,
          title: const Text('المستخدمين'),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.loading.value && controller.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.fetchUsers,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) => _UserTile(controller.users[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: controller.users.length,
            ),
          );
        }),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile(this.u);
  final UserModel u;

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: brown,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const Icon(Icons.chevron_left, color: Colors.white),
        trailing: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          backgroundImage: u.avatarUrl.isEmpty
              ? null
              : NetworkImage(u.avatarUrl),
          child: u.avatarUrl.isEmpty
              ? const Icon(Icons.person, color: brown)
              : null,
        ),
        title: Text(
          u.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${u.phone} • ${u.role}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
