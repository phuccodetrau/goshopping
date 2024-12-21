import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/food_service.dart';

class FoodRepository {
  final FoodService _foodService;
  final FlutterSecureStorage _storage;

  FoodRepository({
    required FoodService foodService,
    FlutterSecureStorage? storage,
  }) : _foodService = foodService,
       _storage = storage ?? const FlutterSecureStorage();

  Future<List<dynamic>> getItemsWithPagination({
    required String groupId,
    required String keyword,
    required int page,
    required int limit,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.filterItemsWithPagination(
        token,
        groupId,
        keyword,
        page,
        limit,
      );

      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get items: $e');
    }
  }

  Future<List<dynamic>> getUnavailableFoods(String groupId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.getUnavailableFoods(token, groupId);

      if (response['code'] == 600) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get unavailable foods: $e');
    }
  }

  Future<void> addFood(Map<String, dynamic> foodData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.addFood(token, foodData);

      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to add food: $e');
    }
  }

  Future<void> updateFood(String foodId, Map<String, dynamic> foodData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.updateFoodById(token, foodId, foodData);

      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update food: $e');
    }
  }

  Future<void> deleteFood(String foodId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.deleteFood(token, foodId);

      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete food: $e');
    }
  }

  Future<void> updateFoodByName({
    required String oldName,
    required String groupId,
    required Map<String, dynamic> newData,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.updateFood(token, oldName, groupId, newData);

      if (response['code'] != 600 && response['code'] != 602) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update food: $e');
    }
  }

  Future<List<dynamic>> getFoods() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.getFoods(token);
      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get foods: $e');
    }
  }

  Future<void> createFood({
    required String name,
    required String categoryName,
    required String unitName,
    required String image,
    required String groupId,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final foodData = {
        'name': name,
        'categoryName': categoryName,
        'unitName': unitName,
        'image': image,
        'group': groupId,
      };

      final response = await _foodService.createFood(token, foodData);
      if (response['code'] != 600 && response['code'] != 602) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create food: $e');
    }
  }

  Future<void> createUnit({
    required String unitName,
    required String groupId,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final unitData = {
        'unitName': unitName,
        'groupId': groupId,
      };

      final response = await _foodService.createUnit(token, unitData);
      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create unit: $e');
    }
  }

  Future<List<dynamic>> getFoodsByCategory({
    required String groupId,
    required String categoryName,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.getFoodsByCategory(token, {
        'groupId': groupId,
        'categoryName': categoryName,
      });

      if (response['code'] == 600) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get foods by category: $e');
    }
  }

  Future<List<dynamic>> getCategories(String groupId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.getCategories(token, groupId);
      if (response['code'] == 707) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<List<dynamic>> getUnits(String groupId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.getUnits(token, groupId);
      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get units: $e');
    }
  }

  Future<String> getFoodImage(
      {required String groupId, required String foodName}) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _foodService.getFoodImage(token, {
        'groupId': groupId,
        'foodName': foodName,
      });
      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get food image: $e');
    }
  }
} 