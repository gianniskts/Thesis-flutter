import 'store.dart';

class Listing {
  final String id;
  final String category; // Surprise bag, pizza, etc.
  final String description;
  final double firstPrice;
  final double discountedPrice;
  final Map<String, dynamic> location;
  final String storeId; // Reference to the store where the product is available
  final int quantityAvailable;
  final DateTime availabilityStartDate;
  final DateTime availabilityEndDate;
  final List<String> tags; // Meal, Groceries, Veg
  final Store store;
  final int distance;

  Listing({
    required this.id,
    required this.category,
    required this.description,
    required this.firstPrice,
    required this.discountedPrice,
    required this.location,
    required this.storeId,
    required this.quantityAvailable,
    required this.availabilityStartDate,
    required this.availabilityEndDate,
    required this.tags,
    required this.store,
    required this.distance,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    List<String> tagList = List<String>.from(json['tags']);
    int distance = 0;
    if (json['dist'] is int) {
      distance = json['dist'];
    } else if (json['dist'] is Map<String, dynamic> &&
        json['dist'].containsKey('calculated')) {
      distance = json['dist']['calculated'];
    }

    return Listing(
        id: json['_id'] ?? json['id'],
        category: json['category'],
        description: json['description'],
        firstPrice: (json['first_price'] ?? 0.0).toDouble(),
        discountedPrice: (json['discounted_price'] ?? 0.0).toDouble(),
        location: json['location'],
        storeId: json['store_id'],
        quantityAvailable: json['quantity_available'] ?? 0,
        availabilityStartDate: DateTime.parse(json['availability_start_date']),
        availabilityEndDate: DateTime.parse(json['availability_end_date']),
        tags: tagList,
        // Adjust the following line based on where you actually get the 'store_info' and 'dist' in your actual JSON.
        store: Store.fromJson(json[
            'store_info']), // Assuming Store has a proper `fromJson` method
        distance: distance);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'first_price': firstPrice,
        'discounted_price': discountedPrice,
        'location': location,
        'store_id': storeId,
        'quantity_available': quantityAvailable,
        'availability_start_date': availabilityStartDate.toIso8601String(),
        'availability_end_date': availabilityEndDate.toIso8601String(),
        'tags': tags,
        'store_info': store.toJson(),
        'dist': distance,
      };
}
