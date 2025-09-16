import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/drivers_controller.dart';
import '../../data/models/driver_model.dart';

class DriversView extends GetView<DriversController> {
  const DriversView({super.key});

  static const brown = Color(0xFF6F3F17);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: brown,
          title: const Text('السائقين'),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.loading.value && controller.drivers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.fetchDrivers,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) =>
                  _DriverTile(controller.drivers[i] as DriverModel),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: controller.drivers.length,
            ),
          );
        }),
      ),
    );
  }
}

class _DriverTile extends StatelessWidget {
  const _DriverTile(this.d);
  final DriverModel d;

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
          backgroundImage: d.avatarUrl.isEmpty
              ? null
              : NetworkImage(d.avatarUrl),
          child: d.avatarUrl.isEmpty
              ? const Icon(Icons.delivery_dining, color: brown)
              : null,
        ),
        title: Text(
          d.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${d.phone} • ${d.vehicle} • ${d.status}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
