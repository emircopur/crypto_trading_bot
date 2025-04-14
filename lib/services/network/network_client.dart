import 'package:http/http.dart' as http;
import '../token_manager.dart';

class NetworkClient {
  static const String baseUrl = 'https://strapi.bkomain.keenetic.pro/api';
  final _tokenService = TokenService();

  Future<Map<String, String>> getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri url(String path) => Uri.parse('$baseUrl$path');

  http.Client get client => http.Client();
}
