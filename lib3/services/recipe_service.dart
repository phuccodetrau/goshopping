import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  RecipeService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> getAllRecipes(String token, String groupId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/recipe/getAllRecipe'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "group": groupId
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getRecipeDetail(String token, String recipeName, String groupId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/recipe/getAllFoodInReceipt'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "recipeName": recipeName,
        "group": groupId
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addRecipe(String token, Map<String, dynamic> recipeData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/recipe/addRecipe'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(recipeData),
    );
    return jsonDecode(response.body);
  }
}
