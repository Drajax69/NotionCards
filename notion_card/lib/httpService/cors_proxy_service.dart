import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class CorsProxyService {
  final String baseUrl;
  final String corsProxyUrl = 'https://corsproxy.io/?';

  CorsProxyService({required this.baseUrl});

  Future<http.Response> post(String endpoint, Map<String, String> headers,
      Map<String, String> body) async {
    final String proxyUrl = '$corsProxyUrl$baseUrl$endpoint';

    try {
      final response = await http.post(Uri.parse(proxyUrl),
          headers: headers, body: jsonEncode(body));
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
