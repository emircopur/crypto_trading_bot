// lib/services/auth/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/network_client.dart';
import '../token_manager.dart';

class AuthService {
  final NetworkClient _network = NetworkClient();
  final TokenService _tokenService = TokenService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      _network.url('/auth/local'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': email,
        'password': password,
        'requestRefresh': true,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _tokenService.setToken(data['jwt']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      _network.url('/auth/local/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _tokenService.setToken(data['jwt']);
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    await _tokenService.clearToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _tokenService.getToken();
    return token != null;
  }
}
