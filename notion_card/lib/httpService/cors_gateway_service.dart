import 'package:http/http.dart' as http;
import 'dart:convert';

class CorsGatewayService {
  final String baseUrl;
  final String corsAnywhereUrl = 'https://cors-anywhere.herokuapp.com/';

  CorsGatewayService(this.baseUrl);

  Future<http.Response> post(
      String endpoint, Map<String, String> headers) async {
    final String proxyUrl = '$corsAnywhereUrl$baseUrl$endpoint';

    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: headers,
      );
      return response;
    } catch (e) {
      // Handle error or propagate it
      rethrow;
    }
  }
}
