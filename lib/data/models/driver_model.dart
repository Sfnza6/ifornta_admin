class DriverModel {
  final int id;
  final String name;
  final String phone;
  final String vehicle;
  final String status; // active/inactive/blocked...
  final String avatarUrl;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.status,
    required this.avatarUrl,
  });

  factory DriverModel.fromJson(Map<String, dynamic> j) {
    int i(v) => int.tryParse('${v ?? 0}') ?? 0;
    String s(v) => (v ?? '').toString();
    return DriverModel(
      id: i(j['id']),
      name: s(j['name']),
      phone: s(j['phone']),
      vehicle: s(j['vehicle']),
      status: s(j['status'] ?? 'active'),
      avatarUrl: s(j['avatar_url']),
    );
  }
}
