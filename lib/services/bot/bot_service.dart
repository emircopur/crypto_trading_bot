// lib/services/bot/bot_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/network_client.dart';

class BotService {
  final NetworkClient _network = NetworkClient();

  Future<List<dynamic>> getBots() async {
    final headers = await _network.getHeaders();
    final response = await http.get(_network.url('/bots'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to get bots: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getBot(int id) async {
    final headers = await _network.getHeaders();
    final response =
        await http.get(_network.url('/bot?id=$id'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get bot: ${response.body}');
    }
  }

  Future<dynamic> createBot(Map<String, dynamic> botData) async {
    final headers = await _network.getHeaders();
    final response = await http.post(
      _network.url('/bot'),
      headers: headers,
      body: jsonEncode(botData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create bot: ${response.body}');
    }
  }

  Future<void> updateBot(int id, Map<String, dynamic> botData) async {
    final headers = await _network.getHeaders();
    final response = await http.put(
      _network.url('/bot?id=$id'),
      headers: headers,
      body: jsonEncode(botData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update bot: ${response.body}');
    }
  }

  Future<void> deleteBot(int id) async {
    final headers = await _network.getHeaders();
    final response = await http.delete(
      _network.url('/bot/?id=$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete bot: ${response.body}');
    }
  }
}
