import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService apiService;
  final FlutterSecureStorage storage;

  UserRepository({
    required this.apiService,
    FlutterSecureStorage? storage,
  }) : this.storage = storage ?? const FlutterSecureStorage();

  Future<User> login(String email, String password, String? deviceToken) async {
    try {
      final response = await apiService.login(email, password, deviceToken);
      
      if (response['status'] == true && response['data'] != null) {
        final userData = response['data'];
        final user = User.fromJson({
          ...userData['user'],
          'token': userData['token'],
        });

        await _saveUserData(user);
        return user;
      }
      throw Exception(response['message'] ?? 'Login failed');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await apiService.register(name, email, password);
      return response['status'] == true;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await apiService.verifyOtp(email, otp);
      return response['status'] == true;
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await apiService.sendVerificationCode(email);
      return response['status'] == true;
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await apiService.forgotPassword(email);
      return response['status'] == true;
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  Future<bool> resetPassword(String email, String newPassword, String otp) async {
    try {
      final response = await apiService.resetPassword(email, newPassword, otp);
      return response['status'] == true;
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  Future<bool> checkLogin(String email) async {
    try {
      final response = await apiService.checkLogin(email);
      return response['status'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserData(User user) async {
    await storage.write(key: 'auth_token', value: user.token);
    await storage.write(key: 'email', value: user.email);
    await storage.write(key: 'id', value: user.id);
    await storage.write(key: 'name', value: user.name);
  }

  Future<String?> getStoredEmail() async {
    return await storage.read(key: 'email');
  }

  Future<void> clearStoredData() async {
    await storage.deleteAll();
  }
}
