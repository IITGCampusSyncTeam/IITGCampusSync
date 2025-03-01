class Merch {
  final String id;
  final String name;
  final String description;
  final double price;
  final String type;
  final List<String> sizes;

  Merch({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.sizes,
  });

  factory Merch.fromJson(Map<String, dynamic> json) {
    return Merch(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? 'Unknown',
      sizes: List<String>.from(json['sizes'] ?? []),
    );
  }

  /// ✅ **Add this method to fix the error**
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type,
      'sizes': sizes,
    };
  }
}
