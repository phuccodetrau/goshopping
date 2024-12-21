import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroupService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  GroupService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> getUserGroups(String email, String? token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/groups/get-groups-by-member-email?email=$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/groups/leave-group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'groupId': groupId}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteGroup(String groupId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/groups/delete-group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'groupId': groupId}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAdminsByGroupId(String groupId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/groups/get-admins-by-group-id/$groupId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createGroup(String token, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/groups/create-group'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUserNameByEmail(String email, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/user/get-user-name?email=$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> searchUserByEmail(String token, String email) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/user/get-user-name?email=$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addMembersToGroup(String token, Map<String, dynamic> data) async {
    final response = await client.put(
      Uri.parse('$baseUrl/groups/add-member'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> filterItemsWithPagination(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/groups/filterItemsWithPagination'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }


}
