class OrderModel {
  final int id;
  final String customerName;
  final String phone;
  final double total;
  final String type; // توصيل / استلام
  final String status; // pending / processing / success / cancelled

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.total,
    required this.type,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: int.tryParse('${j['id'] ?? j['order_id'] ?? 0}') ?? 0,
    customerName: (j['name'] ?? j['customer_name'] ?? 'الاسم').toString(),
    phone: (j['phone'] ?? '').toString(),
    total: double.tryParse('${j['total'] ?? 0}') ?? 0,
    type: (j['type'] ?? 'توصيل').toString(),
    status: (j['status'] ?? 'pending').toString(),
  );
}
