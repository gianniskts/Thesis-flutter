import 'dart:convert';

import '../model/listing.dart';
import 'base_api.dart';

class ListingApi extends API {
  ListingApi(super.baseUrl);

  Future<Listing> createListing({
    required String category,
    required String description,
    required double firstPrice,
    required double discountedPrice,
    required Map<String, dynamic> location,
    required String storeId,
    required int quantityAvailable,
    required DateTime availabilityStartDate,
    required DateTime availabilityEndDate,
    required List<String> tags,
  }) async {
    final response = await httpClient.post(
      '/listing',
      {
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
      },
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final listData = responseData['listing'];
      return listData['id'];
    } else {
      throw Exception('Failed to create listing: ${response.statusCode}');
    }
  }

  Future<void> updateListingAsSold(String listingId) async {
    final response = await httpClient.post(
      '/payment/$listingId/sold',
      {},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete listing: ${response.statusCode}');
    }
  }
}
