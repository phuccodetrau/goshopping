import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  NotificationService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> getUserInfo(String token, String email) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/user/info?email=$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getNotifications(String token, String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'User-ID': userId,
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> markAllAsRead(String token) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/notifications/read-all'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> markAsRead(String token, String notificationId) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteNotification(String token, String notificationId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/notifications/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
}
