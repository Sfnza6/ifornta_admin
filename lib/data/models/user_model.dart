class UserModel {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    int i(v) => int.tryParse('${v ?? 0}') ?? 0;
    String s(v) => (v ?? '').toString();
    return UserModel(
      id: i(j['id']),
      name: s(j['name']),
      phone: s(j['phone']),
      role: s(j['role'] ?? 'user'),
      avatarUrl: s(j['avatar_url']),
    );
  }
}
