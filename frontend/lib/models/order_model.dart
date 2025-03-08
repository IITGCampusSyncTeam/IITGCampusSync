class Order {
  final String id;
  final String userId; // Who placed the order
  final String merchId; // Which merch was ordered
  final int quantity;
  final double totalPrice;
  final String status; // e.g., "Pending", "Completed", "Cancelled"
  final DateTime orderDate;

  Order({
    required this.id,
    required this.userId,
    required this.merchId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      merchId: json['merchId'] ?? '',
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'merchId': merchId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}
