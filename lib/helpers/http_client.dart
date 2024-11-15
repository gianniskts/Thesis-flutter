// http_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpClient {
  final String baseUrl;

  HttpClient(this.baseUrl);

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),  // JSON encoding is done here
    );
  }

  Future<http.Response> get(String endpoint) {
    return http.get(Uri.parse('$baseUrl$endpoint'));
  }
}
