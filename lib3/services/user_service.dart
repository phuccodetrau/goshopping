import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  UserService({http.Client? client}) : client = client ?? http.Client();

  // Auth APIs
  Future<Map<String, dynamic>> login(String email, String password, String? deviceToken) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'deviceToken': deviceToken
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Login failed');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> checkLogin(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/user/check_login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Check login failed: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {

      final response = await client.post(
        Uri.parse('$baseUrl/auth/user/checkverification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Invalid OTP');
    } catch (e) {
      print('Error verifying OTP: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/user/sendverification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to send code');
    } catch (e) {
      print('Error sending verification code: $e');
      throw Exception('Failed to send verification code');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('Calling forgot password API for email: $email');

      final response = await client.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Forgot password response: $data');
        
        if (data['status'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to send verification code');
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      print('Error in forgot password: $e');
      throw Exception('Forgot password request failed: $e');
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'otp': otp,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      print('Error resetting password: $e');
      if (e is FormatException) {
        throw Exception('Server response format error');
      }
      throw Exception(e.toString().contains('Exception:') ? e.toString() : 'Reset password failed: $e');
    }
  }

  // User APIs
  Future<String> getUserName(String email, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/user/get-user-name?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == true && data['name'] != null) {
        return data['name'];
      }
      throw Exception('Failed to get user name');
    } catch (e) {
      throw Exception('Error fetching user name: $e');
    }
  }
} 