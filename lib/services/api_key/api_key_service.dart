// lib/services/api_keys/api_key_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/network_client.dart';

class ApiKeyService {
  final NetworkClient _network = NetworkClient();

  Future<List<dynamic>> getApiKeys() async {
    final headers = await _network.getHeaders();
    final response =
        await http.get(_network.url('/my-api-keys'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get API keys: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addApiKey(
      String exchange, String marketType, String key, String secretKey) async {
    final headers = await _network.getHeaders();

    // İstek gövdesini oluştur
    final requestBody = {
      'exchange': exchange.toLowerCase(),
      'market_type': marketType.toLowerCase(),
      'key': key,
      'secret_key': secretKey,
    };

    print('Request URL: ${_network.url('/add-key')}');
    print('Request Headers: $headers');
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      _network.url('/add-key'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to add API key: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteApiKey(int id) async {
    final headers = await _network.getHeaders();
    final response = await http.delete(
      _network.url('/delete-key?id=$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete API key: ${response.body}');
    }
  }
}
