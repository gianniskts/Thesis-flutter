import 'dart:convert';
import 'base_api.dart';
import '../model/product.dart';

class ProductAPI extends API {
  ProductAPI(super.baseUrl);

  // Create a new product for a specific store
  Future<Product> createProductForStore(String storeId, Product product) async {
    final response = await httpClient.post(
      '/store/$storeId/product',
      {
        'type': product.type,
        'rating': product.rating,
        'hours': product.hours,
        'price_before': product.priceBefore,
        'price_after_discount': product.priceAfterDiscount,
        'description': product.description,
      },
    );

    if (response.statusCode == 201) {
      // Assuming the updated store document is returned, and you're extracting the last product added to the store's products list
        final productJson = jsonDecode(response.body)['product'];
        return Product.fromJson(productJson);
    } else {
      throw Exception('Failed to create product for store: ${response.statusCode}');
    }
  }

  // ... Other product API methods (getProductById, updateProduct, deleteProduct) go here...
}
