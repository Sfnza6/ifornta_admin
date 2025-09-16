import 'dart:convert';

class CategoryModel {
  final int id;
  final String name;
  final String image; // رابط الصورة
  final bool active;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.active,
  });

  CategoryModel copyWith({int? id, String? name, String? image, bool? active}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      active: active ?? this.active,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> j) {
    int i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
    String s(dynamic v) => (v ?? '').toString();
    bool b(dynamic v) {
      final str = (v ?? '1').toString();
      return str == '1' || str.toLowerCase() == 'true';
    }

    return CategoryModel(
      id: i(j['id']),
      name: s(j['name']),
      image: s(j['image_url'] ?? j['image']), // يدعم الحالتين
      active: b(j['active'] ?? j['is_active']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': image,
    'active': active ? 1 : 0,
  };

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CategoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
