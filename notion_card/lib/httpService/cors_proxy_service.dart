import 'dart:developer';

import 'package:http/http.dart' as http;

class CorsProxyService {
  final String baseUrl;
  final String corsProxyUrl = 'https://corsproxy.io/?';

  CorsProxyService({required this.baseUrl});

  Future<http.Response> post(
      String endpoint, Map<String, String> headers) async {
    final String proxyUrl = '$corsProxyUrl$baseUrl$endpoint';

    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: headers,
      );
      return response;
    } catch (e) {
      log(
        '[proxy-service] Error: $e',
      );
      // Handle error or propagate it
      rethrow;
    }
  }
}
