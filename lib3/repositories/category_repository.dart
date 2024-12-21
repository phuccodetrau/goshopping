import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService;
  final FlutterSecureStorage _storage;

  CategoryRepository({
    required CategoryService categoryService,
    FlutterSecureStorage? storage,
  }) : _categoryService = categoryService,
       _storage = storage ?? const FlutterSecureStorage();

  Future<List<dynamic>> getAllCategories(String groupId) async {
    try {
      final categories = await _categoryService.getAllCategories(groupId);
      return categories;
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<void> updateCategory({
    required String groupId,
    required String oldCategoryName,
    required String newCategoryName,
  }) async {
    try {
      final response = await _categoryService.updateCategory(
        groupId,
        oldCategoryName,
        newCategoryName,
      );
      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory({
    required String groupId,
    required String categoryName,
  }) async {
    try {
      await _categoryService.deleteCategory(groupId, categoryName);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<List<dynamic>> getCategories(String groupId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _categoryService.getCategories(token, groupId);
      if (response['code'] == 707) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<void> createCategory({
    required String categoryName,
    required String groupId,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _categoryService.createCategory(
        token,
        {
          'categoryName': categoryName,
          'groupId': groupId,
        },
      );

      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }
}
