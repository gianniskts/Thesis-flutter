class Product {
  final String id;
  final String type;
  final double rating;
  final String hours;
  final double priceBefore;
  final double priceAfterDiscount;
  final String description;

  Product({
    required this.id,
    required this.type,
    required this.rating,
    required this.hours,
    required this.priceBefore,
    required this.priceAfterDiscount,
    this.description = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      type: json['type'],
      rating: json['rating'],
      hours: json['hours'],
      priceBefore: json['price_before'],
      priceAfterDiscount: json['price_after_discount'],
      description: json['description'],
    );
  }
}
