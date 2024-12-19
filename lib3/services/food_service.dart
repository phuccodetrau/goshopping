import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FoodService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  FoodService({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createFood(Map<String, dynamic> foodData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/createFood'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(foodData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating food: $e');
    }
  }

  Future<List<dynamic>> getAllFood(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getAllFood'),
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
        throw Exception('Failed to fetch food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching food: $e');
    }
  }

  Future<List<dynamic>> getUnavailableFoods(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse('$baseUrl/getUnavailableFoods/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch unavailable foods: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching unavailable foods: $e');
    }
  }

  Future<Map<String, dynamic>> deleteFood(String foodName, String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/deleteFood'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'foodName': foodName, 'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting food: $e');
    }
  }

  Future<Map<String, dynamic>> updateFood(Map<String, dynamic> foodData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/updateFood'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(foodData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating food: $e');
    }
  }

  Future<Map<String, dynamic>> getFoodImageByName(String foodName, String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getFoodImageByName'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'foodName': foodName, 'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch food image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching food image: $e');
    }
  }

  Future<List<dynamic>> getFoodsByCategory(String categoryName, String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getFoodsByCategory'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'categoryName': categoryName, 'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch foods by category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching foods by category: $e');
    }
  }
}
