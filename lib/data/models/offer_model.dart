import 'dart:convert';

class OfferModel {
  final int id;
  final String title; // عنوان التخفيض
  final String imageUrl; // رابط الصورة (كامل)
  final double? price; // اختياري لبادج السعر

  const OfferModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.price,
  });

  factory OfferModel.fromJson(Map<String, dynamic> j) {
    int i(v) => int.tryParse('${v ?? 0}') ?? 0;
    double? d(v) {
      final s = '${v ?? ''}'.trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    String s(v) => (v ?? '').toString();

    // يدعم مفاتيح مختلفة شائعة من الـPHP
    return OfferModel(
      id: i(j['id']),
      title: s(j['title'] ?? j['name'] ?? j['caption']),
      imageUrl: s(j['image_url'] ?? j['image'] ?? j['photo']),
      price: d(j['price']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_url': imageUrl,
    if (price != null) 'price': price,
  };

  OfferModel copyWith({
    int? id,
    String? title,
    String? imageUrl,
    double? price, // ضع null صراحة لإخفاء السعر
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price,
    );
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is OfferModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
