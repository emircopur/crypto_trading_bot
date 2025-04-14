// lib/services/order/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/network_client.dart';

class OrderService {
  final NetworkClient _network = NetworkClient();

  Future<List<dynamic>> getOrders() async {
    final headers = await _network.getHeaders();
    final response = await http.get(_network.url('/orders'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get orders: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final headers = await _network.getHeaders();
    final response =
        await http.get(_network.url('/order?id=$id'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get order: ${response.body}');
    }
  }

  Future<void> updateOrder(int id, Map<String, dynamic> orderData) async {
    final headers = await _network.getHeaders();
    final response = await http.put(
      _network.url('/order?id=$id'),
      headers: headers,
      body: jsonEncode(orderData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order: ${response.body}');
    }
  }
}
