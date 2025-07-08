class FoodItem {
  String imageUrl;
  String name;
  double totalPrice;
  int quantity;

  FoodItem({
    required this.imageUrl,
    required this.name,
    required this.totalPrice,
    required this.quantity,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    double large = (json['LargePrice'] ?? 0).toDouble();
    double medium = (json['MediumPrice'] ?? 0).toDouble();
    double small = (json['SmallPrice'] ?? 0).toDouble();
    return FoodItem(
      imageUrl: json['MenuImage'] ?? '',
      name: json['DisName'] ?? '',
      totalPrice: large + medium + small,
      quantity: 0,
    );
  }
}
