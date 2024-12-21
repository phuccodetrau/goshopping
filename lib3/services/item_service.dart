import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ItemService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  ItemService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> getItemDetail(String token, String foodName, String groupId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/item/getItemDetail'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "foodName": foodName,
        "group": groupId
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAllFood(String token, String groupId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/getAllFood'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "groupId": groupId
      }),
    );
    return jsonDecode(response.body);
  }
}
