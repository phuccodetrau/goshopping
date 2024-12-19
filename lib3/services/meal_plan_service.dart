import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MealPlanService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  MealPlanService({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createMealPlan(Map<String, dynamic> mealPlanData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/createMealPlan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(mealPlanData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create meal plan: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating meal plan: $e');
    }
  }

  Future<List<dynamic>> getMealPlanByDate(String groupId, String date) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getMealPlanByDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'groupId': groupId, 'date': date}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch meal plan by date: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching meal plan by date: $e');
    }
  }

  Future<Map<String, dynamic>> deleteMealPlan(String mealPlanId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/deleteMealPlan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mealPlanId': mealPlanId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete meal plan: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting meal plan: $e');
    }
  }

  Future<Map<String, dynamic>> updateMealPlan(Map<String, dynamic> mealPlanData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/updateMealPlan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(mealPlanData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update meal plan: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating meal plan: $e');
    }
  }

  Future<Map<String, dynamic>> getMealPlanStats(Map<String, dynamic> filterData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getMealPlanStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch meal plan stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching meal plan stats: $e');
    }
  }

  Future<Map<String, dynamic>> getMealPlanStatsByRecipe(Map<String, dynamic> filterData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getMealPlanStatsByRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch meal plan stats by recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching meal plan stats by recipe: $e');
    }
  }

  Future<Map<String, dynamic>> getMealPlanStatsByDate(Map<String, dynamic> filterData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getMealPlanStatsByDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch meal plan stats by date: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching meal plan stats by date: $e');
    }
  }
}
