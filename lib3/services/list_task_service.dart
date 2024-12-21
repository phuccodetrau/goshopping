import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListTaskService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  ListTaskService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> createListTask(String token, Map<String, dynamic> taskData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/listtask/createListTask'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(taskData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getTasksByGroup(String token, String groupId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/listtask/get-tasks-by-group/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateTaskState(String token, String taskId, bool state) async {
    final response = await client.put(
      Uri.parse('$baseUrl/listtask/update-task-state/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'state': state}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteTask(String token, String taskId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/listtask/delete-task/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(response.body);
  }

  // Thêm vào list_task_service.dart
Future<Map<String, dynamic>> updateListTaskById(String token, Map<String, dynamic> taskData) async {
  final response = await client.post(
    Uri.parse('$baseUrl/listtask/updateListTaskById'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(taskData),
  );
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> getTaskStats(String token, Map<String, dynamic> data) async {
  final response = await client.post(
    Uri.parse('$baseUrl/listtask/getTaskStats'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );
  return jsonDecode(response.body);
}

  Future<Map<String, dynamic>> getAllListTasksByGroupPaginated(
    String token,
    String groupId,
    String state,
    String? startDate,
    String? endDate,
    int page,
    int limit,
  ) async {
    final data = {
      'group': groupId,
      'state': state,
      'startDate': startDate ?? '',
      'endDate': endDate ?? '',
      'page': page,
      'limit': limit,
    };

    final response = await client.post(
      Uri.parse('$baseUrl/listtask/getAllListTasksByGroup'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getListTasksByNameAndGroupPaginated(
    String token,
    String name,
    String groupId,
    String state,
    String? startDate,
    String? endDate,
    int page,
    int limit,
  ) async {
    final data = {
      'name': name,
      'group': groupId,
      'state': state,
      'startDate': startDate ?? '',
      'endDate': endDate ?? '',
      'page': page,
      'limit': limit,
    };

    final response = await client.post(
      Uri.parse('$baseUrl/listtask/getListTasksByNameAndGroup'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createItemFromListTaskWithExtra(
    String token,
    String listTaskId,
    int extraDays,
    String note,
  ) async {
    final data = {
      'listTaskId': listTaskId,
      'extraDays': extraDays,
      'note': note,
    };

    final response = await client.post(
      Uri.parse('$baseUrl/listtask/createItemFromListTask'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addItemToRefrigeratorFromTask(
    String token,
    String groupId,
    Map<String, dynamic> item,
  ) async {
    final data = {
      'groupId': groupId,
      'item': item,
    };

    final response = await client.post(
      Uri.parse('$baseUrl/groups/addItemToRefrigerator'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
