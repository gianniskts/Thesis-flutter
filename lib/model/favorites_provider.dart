import 'package:flutter/cupertino.dart';

import '../api/user_api.dart';
import 'listing.dart';
import 'user.dart';

class FavoritesProvider with ChangeNotifier {
  final UserAPI userAPI = UserAPI('http://127.0.0.1:5000');
  User? currentUser;
  List<Listing>? favoriteListings;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      currentUser = await UserService.getUser();
      if (currentUser != null) {
        double latitude = currentUser!.location['latitude'];
        double longitude = currentUser!.location['longitude'];
        favoriteListings = await userAPI.getUserFavourites(
            currentUser!.email, latitude, longitude);
        notifyListeners();
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> addFavorite(
      Listing listing, String email, String storeId, UserAPI userAPI) async {
    favoriteListings?.add(listing);
    notifyListeners();
    // Call API to add to favorites, handle any errors as needed
    userAPI.addToFavourites(email, storeId);
  }

  Future<void> removeFavorite(
      Listing listing, String email, String storeId, UserAPI userAPI) async {
    favoriteListings?.removeWhere((item) => item.id == listing.id);
    notifyListeners();
    // Call API to remove from favorites, handle any errors as needed
    userAPI.removeFromFavourites(email, storeId);
  }

  bool isFavorite(Listing listing) {
    return favoriteListings?.any((item) => item.id == listing.id) ?? false;
  }
}
