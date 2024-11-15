import 'base_api.dart';

class RatingApi extends API {
  RatingApi(super.baseUrl);

  Future<void> createRating({
    required String storeId,
    required String userEmail,
    required double rating,
    String? comment,
  }) async {
    final response = await httpClient.post(
      '/rating/create_rating',
      {
        'store_id': storeId,
        'user_email': userEmail,
        'rating': rating,
        'comment': comment ?? '',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create rating: ${response.statusCode}');
    }
  }

  // Add other methods related to ratings if needed
}
