import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecipeService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  RecipeService({http.Client? client}) : this.client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/createRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(recipeData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  Future<List<dynamic>> getRecipeByFood(String foodName) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getRecipeByFood'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'foodName': foodName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch recipes by food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes by food: $e');
    }
  }

  Future<Map<String, dynamic>> deleteRecipe(String recipeId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/deleteRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'recipeId': recipeId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }

  Future<Map<String, dynamic>> updateRecipe(Map<String, dynamic> recipeData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/updateRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(recipeData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  Future<List<dynamic>> getAllRecipes(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getAllRecipe'),
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
        throw Exception('Failed to fetch all recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching all recipes: $e');
    }
  }

  Future<List<dynamic>> getAllFoodInReceipt(String recipeName) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getAllFoodInReceipt'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'recipeName': recipeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch all food in receipt: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching all food in receipt: $e');
    }
  }
}
