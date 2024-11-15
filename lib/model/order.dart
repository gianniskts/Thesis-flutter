import 'listing.dart';
import 'user.dart';

class OrderDetails {
  User user;
  Listing listing;
  int quantity;

  OrderDetails({
    required this.user,
    required this.listing,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'listing': listing.toJson(),
        'quantity': quantity,
      };

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      user: User.fromJson(json['user']),
      listing: Listing.fromJson(json['listing']),
      quantity: json['quantity'],
    );
  }
}
