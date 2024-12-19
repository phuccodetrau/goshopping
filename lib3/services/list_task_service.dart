import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ListTaskService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ListTaskService({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createListTask(Map<String, dynamic> taskData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/createListTask'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create list task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating list task: $e');
    }
  }

  Future<List<dynamic>> getAllListTasksByGroup(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getAllListTasksByGroup'),
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
        throw Exception('Failed to fetch list tasks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching list tasks: $e');
    }
  }

  Future<List<dynamic>> getListTasksByNameAndGroup(String groupId, String name) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getListTasksByNameAndGroup'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'groupId': groupId, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch list tasks by name: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching list tasks by name: $e');
    }
  }

  Future<Map<String, dynamic>> createItemFromListTask(Map<String, dynamic> taskData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/createItemFromListTask'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create item from list task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating item from list task: $e');
    }
  }

  Future<Map<String, dynamic>> updateListTaskById(Map<String, dynamic> taskData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/updateListTaskById'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update list task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating list task: $e');
    }
  }

  Future<Map<String, dynamic>> deleteListTaskById(String taskId) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/deleteListTaskById'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskId': taskId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete list task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting list task: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskStats(Map<String, dynamic> filterData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getTaskStats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch task stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching task stats: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskStatsByFood(Map<String, dynamic> filterData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getTaskStatsByFood'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch task stats by food: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching task stats by food: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskStatsByDate(Map<String, dynamic> filterData) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse('$baseUrl/getTaskStatsByDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filterData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch task stats by date: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching task stats by date: $e');
    }
  }
}
