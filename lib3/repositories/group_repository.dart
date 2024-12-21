import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupRepository {
  final GroupService _groupService;
  final FlutterSecureStorage _storage;

  GroupRepository({
    required GroupService groupService,
    FlutterSecureStorage? storage,
  })  : _groupService = groupService,
        _storage = storage ?? const FlutterSecureStorage();

  Future<List<Group>> getUserGroups(String email) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _groupService.getUserGroups(email, token);
      if (response['code'] == 700) {
        final List<dynamic> groupsData = response['data'];
        return groupsData.map((data) => Group.fromJson(data)).toList();
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to fetch user groups: $e');
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      final response = await _groupService.leaveGroup(groupId);
      return response['code'] == 700;
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      final response = await _groupService.deleteGroup(groupId);
      return response['code'] == 700;
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  Future<List<String>> getAdminsByGroupId(String groupId) async {
    try {
      final response = await _groupService.getAdminsByGroupId(groupId);
      if (response['code'] == 700) {
        final List<dynamic> admins = response['data'];
        return admins.map((admin) => admin.toString()).toList();
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get admins: $e');
    }
  }

  Future<void> createGroup(String token, Map<String, dynamic> data) async {
    try {
      final response = await _groupService.createGroup(token, data);
      if (response['code'] != 700) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  Future<String?> getUserNameByEmail(String email, String token) async {
    try {
      final response = await _groupService.getUserNameByEmail(email, token);
      if (response['status'] == true) {
        return response['name'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user name: $e');
    }
  }

  Future<Map<String, String>?> searchUserByEmail(String email) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _groupService.searchUserByEmail(token, email);
      if (response['status'] == true && response['name'] != null) {
        return {
          'name': response['name'],
          'email': email,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to search user: $e');
    }
  }

  Future<bool> addMembersToGroup({
    required String groupId,
    required List<Map<String, String>> members,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final membersData = members.map((user) => {
        'name': user['name'],
        'email': user['email'],
        'role': 'user',
      }).toList();

      final data = {
        'groupId': groupId,
        'members': membersData,
      };

      final response = await _groupService.addMembersToGroup(token, data);
      return response['code'] == 200;
    } catch (e) {
      throw Exception('Failed to add members: $e');
    }
  }

  Future<List<dynamic>> getItemsWithPagination({
    required String groupId,
    required String keyword,
    required int page,
    required int limit,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _groupService.filterItemsWithPagination(
        token,
        {
          'groupId': groupId,
          'keyword': keyword,
          'page': page,
          'limit': limit,
        },
      );

      if (response['code'] == 700) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get items: $e');
    }
  }

  
} 