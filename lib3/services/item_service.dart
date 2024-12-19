import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ItemService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ItemService({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> itemData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/createItem'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(itemData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating item: $e');
    }
  }

  Future<List<dynamic>> getAllItems(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getAllItem'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch items: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }

  Future<Map<String, dynamic>> getSpecificItem(String itemId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getSpecificItem'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'itemId': itemId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch specific item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching specific item: $e');
    }
  }

  Future<Map<String, dynamic>> deleteItem(String itemId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/deleteItem'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'itemId': itemId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting item: $e');
    }
  }

  Future<Map<String, dynamic>> updateItem(Map<String, dynamic> itemData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/updateItem'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(itemData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }

  Future<Map<String, dynamic>> getItemDetail(String itemId, String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getItemDetail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'itemId': itemId, 'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch item detail: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching item detail: $e');
    }
  }
}
