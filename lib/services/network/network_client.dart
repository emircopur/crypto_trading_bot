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

  Uri url(String path) {
    // Eğer path zaten tam URL ise, direkt olarak kullan
    if (path.startsWith('http')) {
      return Uri.parse(path);
    }

    // Eğer path / ile başlamıyorsa, / ekle
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    // baseUrl sonunda / varsa kaldır
    String cleanBaseUrl = baseUrl;
    if (cleanBaseUrl.endsWith('/')) {
      cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
    }

    final fullUrl = '$cleanBaseUrl$path';
    print('Generated URL: $fullUrl');
    return Uri.parse(fullUrl);
  }

  http.Client get client => http.Client();
}
