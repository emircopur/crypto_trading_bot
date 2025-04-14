import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  final _storage = const FlutterSecureStorage();

  factory TokenService() {
    return _instance;
  }

  TokenService._internal();

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt');
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
}
