import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/list_task_service.dart';

class ListTaskRepository {
  final ListTaskService _taskService;
  final FlutterSecureStorage _storage;

  ListTaskRepository({
    required ListTaskService taskService,
    FlutterSecureStorage? storage,
  }) : _taskService = taskService,
       _storage = storage ?? const FlutterSecureStorage();

  Future<void> createListTask({
    required String memberName,
    required String memberEmail,
    required String note,
    required DateTime startDate,
    required DateTime endDate,
    required String foodName,
    required int amount,
    required String unitName,
    required String groupId,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final taskData = {
        'memberName': memberName,
        'memberEmail': memberEmail,
        'note': note,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'foodName': foodName,
        'amount': amount,
        'unitName': unitName,
        'state': false,
        'group': groupId,
      };

      final response = await _taskService.createListTask(token, taskData);
      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create list task: $e');
    }
  }

  Future<List<dynamic>> getTasksByGroup(String groupId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _taskService.getTasksByGroup(token, groupId);
      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<void> updateTaskState(String taskId, bool state) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _taskService.updateTaskState(token, taskId, state);
      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update task state: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _taskService.deleteTask(token, taskId);
      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Thêm vào list_task_repository.dart
Future<void> updateListTaskById({
  required String listTaskId,
  required String memberName,
  required String memberEmail,
  required String note,
  required DateTime startDate,
  required DateTime endDate,
  required String foodName,
  required int amount,
  required String unitName,
  required String groupId,
}) async {
  try {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Authentication token not found');

    final taskData = {
      'listTaskId': listTaskId,
      'name': memberName,
      'memberEmail': memberEmail,
      'note': note,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'foodName': foodName,
      'amount': amount,
      'unitName': unitName,
      'state': false,
      'group': groupId,
    };

    final response = await _taskService.updateListTaskById(token, taskData);
    if (response['code'] != 700) {
      throw Exception(response['message']);
    }
  } catch (e) {
    throw Exception('Failed to update list task: $e');
  }
}

Future<Map<String, dynamic>> getTaskStats({
  required String groupId,
  required int month,
  required int year,
}) async {
  try {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Authentication token not found');

    final response = await _taskService.getTaskStats(token, {
      'groupId': groupId,
      'month': month,
      'year': year,
    });

    if (response['code'] == 700) {
      return response['data'];
    }
    throw Exception(response['message']);
  } catch (e) {
    throw Exception('Failed to get task stats: $e');
  }
}

  Future<List<dynamic>> getAllListTasksByGroupPaginated({
    required String groupId,
    required String state,
    String? startDate,
    String? endDate,
    required int page,
    required int limit,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _taskService.getAllListTasksByGroupPaginated(
        token,
        groupId,
        state,
        startDate,
        endDate,
        page,
        limit,
      );

      if (response['code'] == 200) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get all tasks: $e');
    }
  }

  Future<List<dynamic>> getListTasksByNameAndGroupPaginated({
    required String name,
    required String groupId,
    required String state,
    String? startDate,
    String? endDate,
    required int page,
    required int limit,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _taskService.getListTasksByNameAndGroupPaginated(
        token,
        name,
        groupId,
        state,
        startDate,
        endDate,
        page,
        limit,
      );

      if (response['code'] == 200) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get user tasks: $e');
    }
  }

  Future<bool> completeListTaskWithItem({
    required String listTaskId,
    required int extraDays,
    required String note,
    required String groupId,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final createItemResponse = await _taskService.createItemFromListTaskWithExtra(
        token,
        listTaskId,
        extraDays,
        note,
      );

      if (createItemResponse['code'] == 201) {
        final item = createItemResponse['data'];
        
        final addItemResponse = await _taskService.addItemToRefrigeratorFromTask(
          token,
          groupId,
          item,
        );

        if (addItemResponse['code'] == 700) {
          return true;
        }
        throw Exception(addItemResponse['message']);
      }
      throw Exception(createItemResponse['message']);
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }
} 