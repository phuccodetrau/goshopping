import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FoodService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  FoodService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> filterItemsWithPagination(
    String token,
    String groupId,
    String keyword,
    int page,
    int limit,
  ) async {
    final data = {
      'groupId': groupId,
      'keyword': keyword,
      'page': page,
      'limit': limit,
    };

    final response = await client.post(
      Uri.parse('$baseUrl/groups/filterItemsWithPagination'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUnavailableFoods(
    String token,
    String groupId,
  ) async {
    final response = await client.get(
      Uri.parse('$baseUrl/food/getUnavailableFoods/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addFood(
    String token,
    Map<String, dynamic> foodData,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(foodData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateFoodByName(
    String token,
    Map<String, dynamic> foodData,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/updateFood'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(foodData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteFood(
    String token,
    String foodId,
  ) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/food/delete/$foodId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }


  Future<Map<String, dynamic>> getFoods(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/food/get-all-food'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createFood(String token, Map<String, dynamic> foodData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/createFood'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(foodData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createUnit(String token, Map<String, dynamic> unitData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/unit/admin/unit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(unitData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getFoodsByCategory(String token, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/getFoodsByCategory'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getCategories(String token, String groupId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/category/admin/category/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUnits(String token, String groupId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/unit/admin/unit/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getFoodImage(String token, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/getFoodImageByName'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateFoodById(
    String token,
    String foodId,
    Map<String, dynamic> foodData,
  ) async {
    final response = await client.put(
      Uri.parse('$baseUrl/food/update/$foodId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(foodData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateFood(String token, String foodName, String groupId, Map<String, dynamic> newData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/food/updateFood'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'foodName': foodName,
        'group': groupId,
        'newData': newData,
      }),
    );
    return jsonDecode(response.body);
  }

}
