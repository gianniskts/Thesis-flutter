// api/base_api.dart

import '../helpers/http_client.dart';

class API {
  final HttpClient httpClient;

  API(String baseUrl) : httpClient = HttpClient(baseUrl);
}
