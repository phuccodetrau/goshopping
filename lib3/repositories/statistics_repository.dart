import '../services/statistics_service.dart';

class StatisticsRepository {
  final StatisticsService statisticsService;

  StatisticsRepository({required this.statisticsService});

  Future<List<Map<String, dynamic>>> getTaskStats({
    required String groupId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await statisticsService.getTaskStats(
        groupId: groupId,
        month: month,
        year: year,
      );
      
      return List<Map<String, dynamic>>.from(response['stats']);
    } catch (e) {
      print('Error in StatisticsRepository.getTaskStats: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMealPlanStats({
    required String groupId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await statisticsService.getMealPlanStats(
        groupId: groupId,
        month: month,
        year: year,
      );
      
      return {
        'recipeStats': List<Map<String, dynamic>>.from(response['recipeStats']),
        'foodConsumption': List<Map<String, dynamic>>.from(response['foodConsumption']),
      };
    } catch (e) {
      print('Error in StatisticsRepository.getMealPlanStats: $e');
      return {
        'recipeStats': [],
        'foodConsumption': [],
      };
    }
  }
} 