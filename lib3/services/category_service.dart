import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoryService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  CategoryService({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createCategory(String groupId, String categoryName) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/admin/category'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'categoryName': categoryName,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  Future<List<dynamic>> getAllCategories(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse('$baseUrl/admin/category/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<Map<String, dynamic>> updateCategory(String groupId, String oldCategoryName, String newCategoryName) async {
    try {
      final token = await _getToken();
      final response = await client.put(
        Uri.parse('$baseUrl/admin/category'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'oldCategoryName': oldCategoryName,
          'newCategoryName': newCategoryName,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String groupId, String categoryName) async {
    try {
      final token = await _getToken();
      final response = await client.delete(
        Uri.parse('$baseUrl/admin/category'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'categoryName': categoryName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}
