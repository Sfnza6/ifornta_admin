class ItemModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image; // رابط الصورة (نقراه من image_url أو image)
  final int? categoryId;
  final double? discount;

  const ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.categoryId,
    this.discount,
  });

  factory ItemModel.fromJson(Map<String, dynamic> j) {
    int i(v) => int.tryParse('${v ?? 0}') ?? 0;
    double d(v) => double.tryParse('${v ?? 0}') ?? 0.0;
    String s(v) => (v ?? '').toString();

    return ItemModel(
      id: i(j['id']),
      name: s(j['name']),
      description: s(j['description']),
      price: d(j['price']),
      // يدعم الحالتين: image_url أو image
      image: s(j['image_url'] ?? j['image']),
      categoryId: j['category_id'] == null ? null : i(j['category_id']),
      discount: j['discount'] == null ? null : d(j['discount']),
    );
  }

  ItemModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    int? categoryId,
    double? discount,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': image, // نخزن بالرابط الصحيح
      'category_id': categoryId,
      'discount': discount,
    };
  }
}
