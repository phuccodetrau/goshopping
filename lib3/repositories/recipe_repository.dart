import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecipeRepository {
  final RecipeService apiService;
  final FlutterSecureStorage storage;

  RecipeRepository({
    required this.apiService,
    FlutterSecureStorage? storage,
  }) : storage = storage ?? const FlutterSecureStorage();

  Future<List<Recipe>> getAllRecipes(String token, String groupId) async {
    try {
      final response = await apiService.getAllRecipes(token, groupId);
      if (response['code'] == 709 && response['data'] != null) {
        return (response['data'] as List)
            .map((recipe) => Recipe.fromJson(recipe))
            .toList();
      } else if (response['code'] == 708) {
        return [];
      }
      throw Exception(response['message'] ?? 'Failed to fetch recipes');
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  Future<Recipe> getRecipeDetail(String token, String recipeName, String groupId) async {
    try {
      final response = await apiService.getRecipeDetail(token, recipeName, groupId);
      if (response['code'] == 709 && response['data'] != null) {
        return Recipe.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to fetch recipe details');
    } catch (e) {
      throw Exception('Error fetching recipe details: $e');
    }
  }

  Future<bool> addRecipe(String token, Recipe recipe) async {
    try {
      final response = await apiService.addRecipe(token, recipe.toJson());
      return response['code'] == 709;
    } catch (e) {
      throw Exception('Error adding recipe: $e');
    }
  }
} 