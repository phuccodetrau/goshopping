import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/meal_plan_service.dart';

class MealPlanRepository {
  final MealPlanService apiService;
  final FlutterSecureStorage storage;

  MealPlanRepository({
    required this.apiService,
    FlutterSecureStorage? storage,
  }) : storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, List<dynamic>>> getMealPlanByDate(String token, String groupId, String date) async {
    try {
      final response = await apiService.getMealPlanByDate(token, groupId, date);
      
      // Initialize empty meal plan structure
      Map<String, List<dynamic>> mealsByTime = {
        'Bữa sáng': [],
        'Bữa trưa': [],
        'Bữa xế': [],
        'Bữa tối': [],
      };

      if (response['code'] == 700 && response['data'] != null) {
        for (var mealPlan in response['data']) {
          final String course = mealPlan['course'];
          if (mealPlan['listRecipe'] != null && mealsByTime.containsKey(course)) {
            final List<Map<String, dynamic>> recipes = [];
            for (var recipe in mealPlan['listRecipe']) {
              recipes.add({
                'name': recipe['name'] ?? 'Không có tên',
                'description': recipe['description'] ?? '',
                '_id': recipe['_id'],
              });
            }
            mealsByTime[course] = recipes;
          }
        }
      }
      return mealsByTime;
    } catch (e) {
      throw Exception('Error fetching meal plan: $e');
    }
  }

  Future<bool> saveMealPlan(String token, String groupId, String date, String course, List<String> recipeIds, {String? mealPlanId}) async {
    try {
      final Map<String, dynamic> data = {
        "date": date,
        "course": course,
        "recipe_ids": recipeIds,
        "group_id": groupId,
      };

      if (mealPlanId != null) {
        data["mealplan_id"] = mealPlanId;
        final response = await apiService.updateMealPlan(token, data);
        return response['code'] == 700;
      } else {
        final response = await apiService.createMealPlan(token, data);
        return response['code'] == 700;
      }
    } catch (e) {
      throw Exception('Error saving meal plan: $e');
    }
  }

  Future<String?> getMealPlanId(String token, String groupId, String date, String course) async {
    try {
      final response = await apiService.getMealPlanByDate(token, groupId, date);
      if (response['code'] == 700 && response['data'] != null) {
        final mealPlan = response['data'].firstWhere(
          (meal) => meal['course'] == course,
          orElse: () => null,
        );
        return mealPlan?['_id'];
      }
      return null;
    } catch (e) {
      throw Exception('Error getting meal plan ID: $e');
    }
  }

  Future<Map<String, dynamic>> getMealPlanStats({
    required String groupId,
    required int month,
    required int year,
  }) async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await apiService.getMealPlanStats(token, {
        'groupId': groupId,
        'month': month,
        'year': year,
      });

      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get meal plan stats: $e');
    }
  }
} 