import 'dart:convert';
import 'base_api.dart';
import '../model/store.dart';

class StoreAPI extends API {
  StoreAPI(super.baseUrl);

  // In your API class
  Future<Store> createStore({
    required String ownerFirstName,
    required String ownerLastName,
    required String ownerEmail,
    required String ownerPhone,
    String? ownerAddress,
    String? ownerCity,
    String? ownerCountry,
    String? ownerPostalCode,
    String? ownerIBAN,
    required String storeName,
    required storeAddress,
    required storeCity,
    required storePostalCode,
    required storeType,
    required storeAbout,
    required storeEmail,
    required storePhone,
    required storeVAT,
    String? storeWebsite,
    String imageProfileUrl =
        'https://zarifopoulos.com/wp-content/uploads/2019/09/ab-vasilopoulos.jpg',
    String imageBackgroundUrl =
        'https://zarifopoulos.com/wp-content/uploads/2019/09/ab-vasilopoulos.jpg',
  }) async {
    final response = await httpClient.post(
      '/store',
      {
        'owner_first_name': ownerFirstName,
        'owner_last_name': ownerLastName,
        'owner_email': ownerEmail,
        'owner_phone': ownerPhone,
        'owner_address': ownerAddress ?? 'Default Address',
        'owner_city': ownerCity ?? 'Default City',
        'owner_country': ownerCountry ?? 'Default Country',
        'owner_postal_code': ownerPostalCode ?? 'Default Postal Code',
        'owner_iban': ownerIBAN ?? 'Default IBAN',
        'store_name': storeName,
        'store_address': storeAddress,
        'store_city': storeCity,
        'store_postal_code': storePostalCode,
        'store_type': storeType,
        'store_about': storeAbout,
        'store_email': storeEmail,
        'store_phone': storePhone,
        'store_vat': storeVAT,
        'store_website': storeWebsite ?? 'Default Website',
        'image_profile_url': imageProfileUrl,
        'image_background_url': imageBackgroundUrl,
      },
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final storeData = responseData['store'];

      return Store(
        id: jsonDecode(response.body)['store_id'],
        name: storeData['name'],
        address: storeData['address'],
        city: storeData['city'],
        postalCode: storeData['postal_code'],
        type: storeData['type'],
        about: storeData['about'],
        email: storeData['email'],
        phone: storeData['phone'],
        vat: storeData['vat'],
        website: storeData['website'] ?? 'Default Website',
        imageProfileUrl: storeData['image_profile_url'],
        imageBackgroundUrl: storeData['image_background_url'],
        location: storeData['location'],
        products: [], // If the backend returns products, you can map them like before
        rating: storeData['rating'],
        creationDate: storeData['creation_date'],
        mealsCount: storeData['meals_count'],
      );
    } else {
      throw Exception('Failed to create store: ${response.statusCode}');
    }
  }

  Future<Store> loginStore({
    required String storeCode,
    required String storePassword,
  }) async {
    final response = await httpClient.post(
      '/store/login',
      {
        'store_code': storeCode,
        'store_password': storePassword,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final storeData = responseData['store'];
      return Store.fromJson(storeData);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<Store> getStoreById(String storeId) async {
    final response = await httpClient.get('/store/$storeId');
    if (response.statusCode == 200) {
      return Store.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get store: ${response.statusCode}');
    }
  }

  Future<List<Store>> getStoreByName(String storeName) async {
    final response = await httpClient.get('/store/name/$storeName');
    if (response.statusCode == 200) {
      final List<dynamic> storeList = jsonDecode(response.body);
      return storeList.map((storeMap) => Store.fromJson(storeMap)).toList();
    } else {
      throw Exception('Failed to get stores: ${response.statusCode}');
    }
  }

  Future<List<Store>> getNearestStores(double latitude, double longitude,
      [double? maxDistance]) async {
    String url = '/nearest_stores?latitude=$latitude&longitude=$longitude';
    if (maxDistance != null) {
      url += '&max_distance=$maxDistance';
    }

    final response = await httpClient.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> storeList = jsonDecode(response.body);
      return storeList.map((storeMap) => Store.fromJson(storeMap)).toList();
    } else {
      throw Exception('Failed to get nearest stores: ${response.statusCode}');
    }
  }

  Future<List<Store>> getNearestStoresByAdress(String location,
      [double? maxDistance]) async {
    String url = '/nearest_stores?location=$location';
    if (maxDistance != null) {
      url += '&max_distance=$maxDistance';
    }

    final response = await httpClient.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> storeList = jsonDecode(response.body);
      return storeList.map((storeMap) => Store.fromJson(storeMap)).toList();
    } else {
      throw Exception('Failed to get nearest stores: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getStoreLocation(String storeId) async {
    final response = await httpClient.post(
      '/store/get-location',
      {'id': storeId},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
