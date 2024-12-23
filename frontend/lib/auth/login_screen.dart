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
    
    // Cho phép thông báo và thiết lập các cấu hình khác
    OneSignal.Notifications.requestPermission(true);
    
    // Thêm listener để theo dõi trạng thái subscription
    OneSignal.User.pushSubscription.addObserver((state) {
      print('Push subscription state changed: ${state.current.jsonRepresentation()}');
      if (state.current.id != null) {
        print('New device token: ${state.current.id}');
      }
    });

    // Thêm listener cho notification
    OneSignal.Notifications.addClickListener((event) {
      print('Notification clicked: ${event.notification.additionalData}');
    });
  }

  Future<String?> getDeviceToken() async {
    try {
      // Đảm bảo quyền thông báo được cấp
      bool permission = await OneSignal.Notifications.permission;
      if (!permission) {
        permission = await OneSignal.Notifications.requestPermission(true);
      }

      if (!permission) {
        print('Notification permission denied');
        return null;
      }

      // Đợi để OneSignal khởi tạo và đăng ký
      await Future.delayed(Duration(seconds: 3));

      // Lấy thông tin subscription
      final pushSubscription = OneSignal.User.pushSubscription;
      
      // Đảm bảo đăng ký
      if (pushSubscription.optedIn != true) {
        print('Subscribing to push notifications...');
        await OneSignal.User.pushSubscription.optIn();
        // Đợi thêm để đăng ký hoàn tất
        await Future.delayed(Duration(seconds: 2));
      }

      // Lấy token mới sau khi đăng ký
      final token = OneSignal.User.pushSubscription.id;
      print('Device token after registration: $token');

      // Kiểm tra token
      if (token == null || token.isEmpty) {
        print('Failed to get valid device token');
        return null;
      }

      // Kiểm tra token có hợp lệ không
      final isValid = await _validateToken(token);
      if (!isValid) {
        print('Device token validation failed');
        return null;
      }

      return token;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  // Hàm kiểm tra token có hợp lệ không
  Future<bool> _validateToken(String token) async {
    try {
      // Kiểm tra độ dài token
      if (token.length < 10) return false;

      // Kiểm tra định dạng
      if (!token.contains('-')) return false;

      // Log thông tin chi tiết
      print('Token validation passed for: $token');
      print('Token length: ${token.length}');
      print('Token format: valid');

      return true;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  Future<void> login() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Lấy và kiểm tra device token
      String? deviceToken = await getDeviceToken();
      print('Device token to be sent: $deviceToken');

      if (!mounted) return;

      final response = await http.post(
        Uri.parse('${dotenv.env['ROOT_URL']}/auth/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'deviceToken': deviceToken
        }),
      );

      print('Login response: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['status'] == true && responseData['data'] != null) {
          final Map<String, dynamic> data = responseData['data'];
          final String? token = data['token']?.toString();
          final Map<String, dynamic> user = data['user'] ?? {};
          
          if (token != null && token.isNotEmpty) {
            // Lưu thông tin đăng nhập
            await _storage.write(key: 'auth_token', value: token);
            await _storage.write(
              key: 'email', 
              value: user['email']?.toString() ?? ''
            );
            await _storage.write(
              key: 'name', 
              value: user['name']?.toString() ?? ''
            );

            if (!mounted) return;

            // Chuyển đến màn hình chính
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            throw Exception('Token không hợp lệ');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Đăng nhập thất bại');
        }
      } else {
        throw Exception('Đăng nhập thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
