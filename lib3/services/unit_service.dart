import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UnitService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  UnitService({http.Client? client}) : this.client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createUnit(Map<String, dynamic> unitData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/admin/unit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(unitData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create unit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating unit: $e');
    }
  }

  Future<List<dynamic>> getAllUnits(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse('$baseUrl/admin/unit/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch units: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching units: $e');
    }
  }

  Future<Map<String, dynamic>> updateUnit(Map<String, dynamic> unitData) async {
    try {
      final token = await _getToken();
      final response = await client.put(
        Uri.parse('$baseUrl/admin/unit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(unitData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update unit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating unit: $e');
    }
  }

  Future<void> deleteUnit(String unitId) async {
    try {
      final token = await _getToken();
      final response = await client.delete(
        Uri.parse('$baseUrl/admin/unit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'unitId': unitId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete unit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting unit: $e');
    }
  }
}
