import 'listing.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final String city;
  final String postalCode;
  final String type;
  final String about;
  final String email;
  final String phone;
  final String vat;
  final String website;
  final String imageProfileUrl;
  final String imageBackgroundUrl;
  final Map<String, dynamic> location;
  final List<Listing> products;
  final double rating; // You'll need a proper class for reviews later
  final String creationDate;
  final int mealsCount;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.type,
    required this.about,
    required this.email,
    required this.phone,
    required this.vat,
    required this.website,
    required this.imageProfileUrl,
    required this.imageBackgroundUrl,
    required this.location,
    required this.products,
    required this.rating,
    required this.creationDate,
    required this.mealsCount,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List;
    List<Listing> products =
        productList.map((i) => Listing.fromJson(i)).toList();

    return Store(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      type: json['type'],
      about: json['about'],
      email: json['email'],
      phone: json['phone'],
      vat: json['vat'],
      website: json['website'],
      imageProfileUrl: json['image_profile_url'],
      imageBackgroundUrl: json['image_background_url'],
      location: json['location'],
      products: products,
      rating: json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : json['rating'],
      creationDate: json['creation_date'],
      mealsCount: json['meals_count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'postal_code': postalCode,
        'type': type,
        'about': about,
        'email': email,
        'phone': phone,
        'vat': vat,
        'website': website,
        'image_profile_url': imageProfileUrl,
        'image_background_url': imageBackgroundUrl,
        'location': location,
        'products': products,
        'rating': rating,
        'creation_date': creationDate,
        'meals_count': mealsCount,
      };
}
