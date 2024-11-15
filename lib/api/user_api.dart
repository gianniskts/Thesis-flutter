import 'dart:convert';
import 'package:frontend/model/order.dart';
import 'package:http/http.dart' as http;

import '../model/listing.dart';
import '../model/store.dart';
import '../model/user.dart';
import 'base_api.dart';

class UserAPI extends API {
  UserAPI(super.baseUrl);

  Future<bool> register(
      String name, String email, Map<String, dynamic> location) async {
    final response = await httpClient.post('/register', {
      'name': name,
      'email': email,
      'location':
          location, // This will be the dictionary with latitude and longitude
    });

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await httpClient.post(
      '/login',
      {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> isEmailRegistered(String email) async {
    final response = await httpClient.post(
      '/user/check-email-exists',
      {
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['exists'];
    } else {
      throw Exception('Failed to check email');
    }
  }

  Future<void> sendCode(String email) async {
    final response = await httpClient.post(
      '/user/send_code',
      {'email': email},
    );

    if (response.statusCode != 201) {
      // throw Exception('Failed to send code: ${response.body}');
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    final response = await httpClient.post(
      '/user/verify-code',
      {
        'email': email,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // throw Exception('Failed to verify code: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserLocation(String email) async {
    final response = await httpClient.post(
      '/user/get-location',
      {'email': email},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String email) async {
    final response = await httpClient.post('/user/get-info', {
      'email': email,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      return data;
    } else {
      throw Exception('Failed to get user info: ${response.body}');
    }
  }

  Future<List<dynamic>> getUserFavouriteStoreIds(String email) async {
    final response = await httpClient.post('/user/get-info', {
      'email': email,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> favourites = data['favourites'];

      return favourites;
    } else {
      throw Exception('Failed to get user favourites: ${response.body}');
    }
  }

  Future<User> getUser(String email) async {
    final response = await httpClient.post('/user/get-info', {
      'email': email,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    // const String apiKey = 'AIzaSyDU_9hK7KWSMAT-ASiTHSCMCV79jE-0uZ0';
    // const String apiKey = 'AIzaSyCmgxykjoGzwbS8euFD79nXawSpW6u4Lro';
    const String apiKey = 'AIzaSyB6RsDhueoiMOZAzp1e7ZYl3F6yzHRXYWU';

    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].length > 0) {
        return data['results'][0]['formatted_address'];
      } else {
        throw Exception('Unable to find address for the given coordinates.');
      }
    } else {
      throw Exception(
          'Error fetching address from Google API: ${response.reasonPhrase}');
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    // const String apiKey = 'AIzaSyDU_9hK7KWSMAT-ASiTHSCMCV79jE-0uZ0';
    const String apiKey = 'AIzaSyCmgxykjoGzwbS8euFD79nXawSpW6u4Lro';

    final requestUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&key=$apiKey";

    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['predictions']
            .map<String>((prediction) => prediction['description'])
            .toList();
      }
    }
    return [];
  }

  Future<List<Listing>> getListingsNearby({
    required double latitude,
    required double longitude,
    int maxDistance = 15000,
    int limit = 10,
  }) async {
    String url =
        '/recommended_listings?latitude=$latitude&longitude=$longitude&maxDistance=$maxDistance&limit=$limit';

    final response = await httpClient.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData is List) {
        return responseData.map((listingData) {
          return Listing(
            id: listingData['_id'],
            category: listingData['category'],
            description: listingData['description'],
            firstPrice: listingData['first_price'].toDouble(),
            discountedPrice: listingData['discounted_price'].toDouble(),
            location: listingData['location'],
            storeId: listingData['store_id'],
            quantityAvailable: listingData['quantity_available'],
            availabilityStartDate:
                DateTime.parse(listingData['availability_start_date']),
            availabilityEndDate:
                DateTime.parse(listingData['availability_end_date']),
            tags: listingData['tags'].cast<String>(),
            store: Store.fromJson(listingData['store_info']),
            distance: listingData['dist']['calculated'],
          );
        }).toList();
      }

      return [];
    } else {
      throw Exception('Failed to fetch listings: ${response.body}');
    }
  }

  Future<bool> addToFavourites(String email, String storeId) async {
    final response = await httpClient.post(
      '/user/add-to-favourites',
      {
        'email': email,
        'store_id': storeId, // Changed from listingId to storeId
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['message'] == "Added to favourites successfully!") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> removeFromFavourites(String email, String storeId) async {
    final response = await httpClient.post(
      '/user/remove-from-favourites',
      {
        'email': email,
        'store_id': storeId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['message'] == "Removed from favourites successfully!") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<Listing>> getUserFavourites(
      String email, double latitude, double longitude) async {
    final response = await httpClient.post(
      '/user/get-favourites',
      {
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData.containsKey('favourites') &&
          responseData['favourites'] is List) {
        List<String> favouriteIds = responseData['favourites'].cast<String>();

        // Fetching details for each listing and storing the resulting futures in a list
        List<Future<Listing>> futureListings = favouriteIds
            .map((id) => getListingDetails(id, latitude, longitude))
            .toList();

        // Waiting for all the futures to complete and returning the list of listings
        return await Future.wait(futureListings);
      }
      return [];
    } else {
      return [];
    }
  }

  Future<Listing> getListingDetails(
      String listingId, double latitude, double longitude) async {
    final response = await httpClient
        .get('/listing/$listingId?latitude=$latitude&longitude=$longitude');

    if (response.statusCode == 200) {
      final listingData = jsonDecode(response.body);
      return Listing.fromJson(listingData);
    } else {
      throw Exception('Failed to fetch listing details: ${response.body}');
    }
  }

  Future<List<dynamic>?> getUserOrders1(String email) async {
    final response = await httpClient.get('/user/orders/$email');

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['orders'];
    } else {
      return null;
    }
  }

  Future<List<OrderDetails>> getUserPurchasedOrders(String email) async {
    final response = await httpClient.get('/user/get_purchased_orders/$email');

    if (response.statusCode == 200) {
      List<dynamic> ordersData = jsonDecode(response.body)['purchased_orders'];
      List<OrderDetails> orders = [];

      for (var orderData in ordersData) {
        OrderDetails order = OrderDetails.fromJson(orderData);
        orders.add(order);
      }

      return orders;
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  Future<List<Listing>> getUserPurchasedListings(String email) async {
    final response =
        await httpClient.get('/user/get_purchased_listings/$email');

    if (response.statusCode == 200) {
      List<dynamic> ordersData =
          jsonDecode(response.body)['purchased_listings'];
      List<Listing> orders = [];

      for (var orderData in ordersData) {
        Listing order = Listing.fromJson(orderData);
        orders.add(order);
      }

      return orders;
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  Future<bool> removeUserLiveOrder(String email, String listingId) async {
    final response = await httpClient.get(
        '/user/remove_live_order/$email/$listingId'); // Replace with your API URL

    if (response.statusCode == 200) {
      // Handle success
      return true;
    } else {
      // Handle error
      return false;
    }
  }

  Future<List<OrderDetails>?> getUserLiveOrders(User currentUser) async {
    final response = await httpClient
        .get('/user/get_live_orders/${currentUser.email}'); // Updated API URL

    if (response.statusCode == 200) {
      // Handle success
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == "success" && data['live_orders'].isNotEmpty) {
        List<OrderDetails> orders = [];
        for (var orderData in data['live_orders']) {
          orders.add(OrderDetails(
              user: currentUser,
              listing: Listing.fromJson(orderData['listing']),
              quantity: orderData['quantity']));
        }
        return orders.first.quantity > 0 ? orders : null;
      } else {
        return null;
      }
    } else {
      // Handle error
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserImpact(String email) async {
    try {
      final response = await httpClient.get('/user/calculate_impact/$email');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> createStripeCustomer(String email) async {
    final response = await httpClient.post(
      '/payment/create_customer/$email',
      {},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['customer_id'];
    } else {
      throw Exception('Failed to create Stripe customer');
    }
  }

  Future<bool> changeUserName(String email, String newName) async {
    final response = await httpClient.post(
      '/user/change-name',
      {
        'email': email,
        'new_name': newName,
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteUserAccount(String email) async {
    final response = await httpClient.post(
      '/user/delete-account',
      {
        'email': email,
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> cancelOrder(String orderId, String userEmail) async {
    final response = await httpClient.post(
      '/cancel_order/$orderId/$userEmail',
      {},
    );

    if (response.statusCode == 200) {
      return true; // or return json.decode(response.body) if there's relevant data to return
    } else {
      return false;
    }
  }
}
