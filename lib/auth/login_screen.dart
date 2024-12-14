import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeOneSignal();
  }

  void _initializeOneSignal() {
    // Khởi tạo OneSignal
    OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
    
    // Cho phép thông báo
    OneSignal.Notifications.requestPermission(true);
  }

  Future<String?> getDeviceToken() async {
    try {
      final deviceState = await OneSignal.User.pushSubscription;
      return deviceState.id;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  Future<void> login() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Lấy device token từ OneSignal
      final deviceToken = await getDeviceToken();
      print('Device Token: $deviceToken'); // Debug log
      
      final response = await http.post(
        Uri.parse('${dotenv.env['ROOT_URL']}/auth/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
          'deviceToken': deviceToken
        }),
      );

      print('Login Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true) {
          // Lưu token
          await _storage.write(key: 'auth_token', value: data['data']['token']);
          await _storage.write(key: 'email', value: data['data']['user']['email']);
          await _storage.write(key: 'name', value: data['data']['user']['name']);

          // Chuyển đến màn hình chính
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Đăng nhập thất bại')),
          );
        }
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      print('Login Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi đăng nhập')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
              ),
            ),
            SizedBox(height: 24.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text('Đăng nhập'),
                  ),
          ],
        ),
      ),
    );
  }
}
