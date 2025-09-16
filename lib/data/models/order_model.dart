import 'dart:convert';

class OrderModel {
  final int id;
  final String customerName;
  final String customerPhone;
  final String address;
  final double total;
  final String status; // pending | processing | cancelled | success
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.total,
    required this.status,
    this.createdAt,
  });

  /* ===================== أدوات تحويل ===================== */
  static int _i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    final s = v is num ? v.toString() : v.toString().replaceAll(',', '');
    return double.tryParse(s) ?? 0.0;
  }

  static String _s(dynamic v) => (v ?? '').toString();

  static DateTime? _dt(dynamic v) {
    final s = _s(v).trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  static String _normalizeStatus(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('pend')) return 'pending';
    if (s.contains('process')) return 'processing';
    if (s.contains('cancel')) return 'cancelled';
    if (s.contains('success') || s.contains('done')) return 'success';
    return raw.isEmpty ? 'pending' : raw;
  }

  /* ===================== fromJson ===================== */
  factory OrderModel.fromJson(Map<String, dynamic> j) {
    return OrderModel(
      id: _i(j['id']),
      customerName: _s(j['customer_name']),
      customerPhone: _s(j['customer_phone']),
      address: _s(j['address']),
      total: _d(j['total']),
      status: _normalizeStatus(_s(j['status'])),
      createdAt: _dt(j['created_at']),
    );
  }

  /* ===================== toJson ===================== */
  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'address': address,
    'total': total,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  /* ===================== copyWith ===================== */
  OrderModel copyWith({
    int? id,
    String? customerName,
    String? customerPhone,
    String? address,
    double? total,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /* ===================== مساواة ===================== */
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderModel &&
          other.id == id &&
          other.customerName == customerName &&
          other.customerPhone == customerPhone &&
          other.address == address &&
          other.total == total &&
          other.status == status &&
          other.createdAt == createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      customerName.hashCode ^
      customerPhone.hashCode ^
      address.hashCode ^
      total.hashCode ^
      status.hashCode ^
      createdAt.hashCode;

  @override
  String toString() => 'OrderModel(${toJson()})';
}
