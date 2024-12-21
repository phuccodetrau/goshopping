import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;
  final FlutterSecureStorage _storage;

  NotificationRepository({
    required NotificationService notificationService,
    FlutterSecureStorage? storage,
  }) : _notificationService = notificationService,
       _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getUserId() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final email = await _storage.read(key: 'email');
      
      if (token == null || email == null) {
        throw Exception('Authentication token or email not found');
      }

      final response = await _notificationService.getUserInfo(token, email);
      if (response['status'] == true && response['data'] != null) {
        return response['data']['_id'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user ID: $e');
    }
  }

  Future<List<dynamic>> getNotifications() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userId = await getUserId();
      
      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }

      final response = await _notificationService.getNotifications(token, userId);
      if (response['code'] == 801) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _notificationService.markAllAsRead(token);
      if (response['code'] != 200) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _notificationService.markAsRead(token, notificationId);
      if (response['code'] != 200) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Authentication token not found');

      final response = await _notificationService.deleteNotification(token, notificationId);
      if (response['code'] != 200) {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
} 