import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StatisticsService {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;

  Future<Map<String, dynamic>> getTaskStats({
    required String groupId,
    required int month,
    required int year,
  }) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/listtask/getTaskStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'month': month,
          'year': year,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          return data['data'];
        }
        throw Exception(data['message']);
      }
      throw Exception('Failed to fetch task statistics');
    } catch (e) {
      throw Exception('Error fetching task statistics: $e');
    }
  }

  Future<Map<String, dynamic>> getMealPlanStats({
    required String groupId,
    required int month,
    required int year,
  }) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/meal/getMealPlanStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'month': month,
          'year': year,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          return data['data'];
        }
        throw Exception(data['message']);
      }
      throw Exception('Failed to fetch meal plan statistics');
    } catch (e) {
      throw Exception('Error fetching meal plan statistics: $e');
    }
  }
} 