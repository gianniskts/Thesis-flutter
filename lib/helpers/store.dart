import 'item.dart';

class Store {
  final String storeProfileImageUrl;
  final String storeBackgroundImageUrl;
  final String storeName;
  final String storeLocation;
  final String storeRating;
  final List<Item> storeItems;
  final int storeSavedMeals;
  final String storeDescription;
  final String storeVAT;
  final int storeItemsLeft;

  const Store({
    required this.storeProfileImageUrl,
    required this.storeBackgroundImageUrl,
    required this.storeName,
    required this.storeLocation,
    required this.storeRating,
    this.storeItems = const [],
    required this.storeSavedMeals,
    required this.storeDescription,
    required this.storeVAT,
    this.storeItemsLeft = 0,
  });
}