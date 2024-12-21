import '../services/item_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ItemRepository {
  final ItemService apiService;
  final FlutterSecureStorage storage;

  ItemRepository({
    required this.apiService,
    FlutterSecureStorage? storage,
  }) : storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> getItemDetail(String token, String foodName, String groupId) async {
    try {
      final response = await apiService.getItemDetail(token, foodName, groupId);
      if (response['code'] == 800 && response['data'] != null) {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to fetch item details');
    } catch (e) {
      throw Exception('Error fetching item details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllFood(String token, String groupId) async {
    try {
      final response = await apiService.getAllFood(token, groupId);
      if (response['code'] == 607 && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else if (response['code'] == 608) {
        return [];
      }
      throw Exception(response['message'] ?? 'Failed to fetch foods');
    } catch (e) {
      throw Exception('Error fetching foods: $e');
    }
  }
} 