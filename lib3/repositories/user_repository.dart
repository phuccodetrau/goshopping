import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService apiService;
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

        // Save all user data
        await storage.write(key: 'auth_token', value: user.token);
        await storage.write(key: 'email', value: user.email);
        await storage.write(key: 'id', value: user.id);
        await storage.write(key: 'name', value: user.name);
        if (user.phoneNumber != null) {
          await storage.write(key: 'phoneNumber', value: user.phoneNumber);
        }
        if (user.deviceToken != null) {
          await storage.write(key: 'deviceToken', value: user.deviceToken);
        }

        return user;
      }
      throw Exception(response['message'] ?? 'Login failed');
    } catch (e) {
      print('Login repository error: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await apiService.register(name, email, password);
      
      if (response['status'] == true) {
        // Save user data after successful registration
        if (response['token'] != null) {
          await storage.write(key: 'auth_token', value: response['token']);
        }
        
        final userData = response['user'];
        if (userData != null) {
          await storage.write(key: 'email', value: userData['email']?.toString());
          await storage.write(key: 'id', value: userData['_id']?.toString());
          await storage.write(key: 'name', value: userData['name']?.toString());
          
          print('Stored user name: ${await storage.read(key: 'name')}');
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Register repository error: $e');
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

  Future<String?> getStoredEmail() async {
    return await storage.read(key: 'email');
  }

  Future<void> clearStoredData() async {
    await storage.deleteAll();
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final email = await storage.read(key: 'email');
      final token = await storage.read(key: 'auth_token');
      
      if (email == null || token == null) {
        throw Exception('User not logged in');
      }

      final response = await apiService.getUserInfo(email, token);
      
      if (response['status'] == true && response['data'] != null) {
        final userData = response['data'];
        // Update stored user data
        if (userData['name'] != null) {
          await storage.write(key: 'name', value: userData['name']);
        }
        if (userData['phoneNumber'] != null) {
          await storage.write(key: 'phoneNumber', value: userData['phoneNumber']);
        }
        if (userData['avatar'] != null) {
          await storage.write(key: 'avatar', value: userData['avatar']);
        }
        return userData;
      }
      throw Exception(response['message'] ?? 'Failed to get user info');
    } catch (e) {
      print('Get user info error: $e');
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<bool> updateUserInfo(Map<String, dynamic> data) async {
    try {
      final email = await storage.read(key: 'email');
      final token = await storage.read(key: 'auth_token');
      
      if (email == null || token == null) {
        throw Exception('User not logged in');
      }

      final response = await apiService.updateUserInfo(email, token, data);
      
      if (response['status'] == true) {
        // Update stored user data
        if (data['name'] != null) {
          await storage.write(key: 'name', value: data['name']);
        }
        if (data['phoneNumber'] != null) {
          await storage.write(key: 'phoneNumber', value: data['phoneNumber']);
        }
        if (data['avatar'] != null) {
          await storage.write(key: 'avatar', value: data['avatar']);
        }
        return true;
      }
      throw Exception(response['message'] ?? 'Failed to update user info');
    } catch (e) {
      print('Update user info error: $e');
      throw Exception('Failed to update user info: $e');
    }
  }
}
