import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final String baseUrl = dotenv.env['ROOT_URL'] ?? '';
  final http.Client client;

  UserService({http.Client? client}) : client = client ?? http.Client();

  // Auth APIs
  Future<Map<String, dynamic>> login(String email, String password, String? deviceToken) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'deviceToken': deviceToken
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
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
  }

  Future<Map<String, dynamic>> checkLogin(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/user/check_login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/user/checkverification-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/user/sendverification-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword, String otp) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
        'otp': otp,
      }),
    );
    return jsonDecode(response.body);
  }

  // User Info APIs
  Future<Map<String, dynamic>> getUserInfo(String email, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/user/info?email=$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateUserInfo(String email, String token, Map<String, dynamic> data) async {
    final response = await client.put(
      Uri.parse('$baseUrl/auth/user/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        ...data,
      }),
    );
    return jsonDecode(response.body);
  }
} 