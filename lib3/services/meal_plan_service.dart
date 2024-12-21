import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MealPlanService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  MealPlanService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> getMealPlanByDate(String token, String groupId, String date) async {
    final response = await client.post(
      Uri.parse('$baseUrl/meal/getMealPlanByDate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "group": groupId,
        "date": date,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createMealPlan(String token, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/meal/createMealPlan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateMealPlan(String token, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/meal/updateMealPlan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMealPlanStats(String token, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/meal/getMealPlanStats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
