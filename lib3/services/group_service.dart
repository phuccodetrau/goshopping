import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/group_model.dart';

class GroupService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GroupService({http.Client? client}) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<List<Group>> fetchUserGroups(String email) async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse('$baseUrl/groups/get-groups-by-member-email?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700 && data['data'] != null) {
          return (data['data'] as List)
              .map((group) => Group.fromJson(group))
              .toList();
        }
      }
      throw Exception('Failed to fetch groups');
    } catch (e) {
      throw Exception('Error fetching user groups: $e');
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.delete(
        Uri.parse('$baseUrl/groups/delete-group'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code'] == 700;
      }
      return false;
    } catch (e) {
      throw Exception('Error deleting group: $e');
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      final token = await _getToken();
      final response = await client.delete(
        Uri.parse('$baseUrl/groups/leave-group'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code'] == 700;
      }
      return false;
    } catch (e) {
      throw Exception('Error leaving group: $e');
    }
  }

  Future<Group?> createGroup(String name, List<GroupUser> listUser) async {
    try {
      final token = await _getToken();
      final payload = {
        'name': name,
        'listUser': listUser.map((user) => user.toJson()).toList(),
      };

      final response = await client.post(
        Uri.parse('$baseUrl/groups/create-group'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Group.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  Future<bool> addMembers(String groupId, List<GroupUser> members) async {
    try {
      final token = await _getToken();
      final payload = {
        'groupId': groupId,
        'members': members.map((member) => member.toJson()).toList(),
      };

      final response = await client.put(
        Uri.parse('$baseUrl/groups/add-member'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code'] == 700;
      }
      return false;
    } catch (e) {
      throw Exception('Error adding members: $e');
    }
  }

  Future<Map<String, dynamic>> getAdmins(String groupId, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/get-admins-by-group-id/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch admin data');
    } catch (e) {
      throw Exception('Error fetching admin data: $e');
    }
  }

  Future<Map<String, dynamic>> getUsersByGroupName(
      String groupName, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/get-users-by-group-name?groupName=$groupName'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch users by group name');
    } catch (e) {
      throw Exception('Error fetching users by group name: $e');
    }
  }

  Future<Map<String, dynamic>> getUsersByGroupId(
      String groupId, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/get-users-by-group-id/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch users by group ID');
    } catch (e) {
      throw Exception('Error fetching users by group ID: $e');
    }
  }

  Future<Map<String, dynamic>> addItemToRefrigerator(
      String groupId, Map<String, dynamic> item, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/addItemToRefrigerator'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'item': item,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to add item to refrigerator');
    } catch (e) {
      throw Exception('Error adding item to refrigerator: $e');
    }
  }

  Future<Map<String, dynamic>> filterItemsWithPagination(
      String groupId, String keyword, int page, int limit, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/filterItemsWithPagination/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'keyword': keyword,
          'page': page,
          'limit': limit,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to filter items with pagination');
    } catch (e) {
      throw Exception('Error filtering items with pagination: $e');
    }
  }
}
