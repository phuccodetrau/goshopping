import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_shopping/home_screen/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String URL = dotenv.env['ROOT_URL']! + "/auth/user";

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isAgree = false;
  String? _responseMessage;

  bool get _isButtonEnabled =>
      _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _isAgree &&
          _passwordController.text == _confirmPasswordController.text;

  bool get _isPasswordMatch =>
      _confirmPasswordController.text.isEmpty ||
          _passwordController.text == _confirmPasswordController.text;

  bool get _isUsernameValid => _usernameController.text.isNotEmpty;
  bool get _isEmailValid => _emailController.text.isNotEmpty;
  bool get _isPasswordValid => _passwordController.text.isNotEmpty;
  bool get _isConfirmPasswordValid =>
      _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {}); // Cập nhật giao diện khi người dùng nhập liệu
  }

  void _onAgreeChanged(bool? value) {
    setState(() {
      _isAgree = value ?? false;
    });
  }

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': username, 'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        final String token = responseData['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        await _secureStorage.write(key: 'email', value: responseData['user']['email']);
        await _secureStorage.write(key: 'id', value: responseData['user']['_id'].toString());
        await _secureStorage.write(key:"name",value:responseData['user']['name'].toString());
        print(await _secureStorage.read(key: 'name'));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        final String message=responseData['message'].toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message'),
            backgroundColor: Colors.red, // Màu nền của snackbar
          ),
        );
      }
      setState(() {});
    } catch (e) {
      print(e);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20),
              Text(
                'Chào mừng bạn đến với',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              Text(
                'Đi Chợ Tiện Lợi!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 30),

              // Trường nhập tên người dùng
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your username',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              if (!_isUsernameValid)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Please enter your username',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 10),

              // Trường nhập email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Enter your email',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              if (!_isEmailValid)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Please enter your email',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 10),

              // Trường nhập mật khẩu
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock), // Biểu tượng khóa ở bên trái
                  hintText: 'Enter your password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible1 ? Icons.visibility : Icons.visibility_off, // Biểu tượng mắt
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible1 = !_isPasswordVisible1; // Chuyển đổi trạng thái hiển thị mật khẩu
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible1, // Điều chỉnh xem mật khẩu hay không
                textInputAction: TextInputAction.next,
              ),
              if (!_isPasswordValid)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Please enter your password',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 10),

              // Trường nhập lại mật khẩu
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock), // Biểu tượng khóa bên trái
                  hintText: 'Confirm your password', // Text hiển thị trong ô input
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible2 ? Icons.visibility : Icons.visibility_off, // Biểu tượng mắt
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible2= !_isPasswordVisible2; // Đảo ngược trạng thái hiển thị mật khẩu
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible2, // Điều chỉnh để ẩn/hiện mật khẩu
                textInputAction: TextInputAction.done,
              ),
              if (!_isConfirmPasswordValid)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _confirmPasswordController.text.isEmpty
                        ? 'Please confirm your password'
                        : 'Passwords do not match',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: _isAgree,
                    onChanged: _onAgreeChanged,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Tôi đồng ý với các ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Chính sách quyền riêng tư của Đi Chợ Tiện Lợi',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isButtonEnabled ? _register : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? Colors.green : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text(
                    'Tiếp tục với Email',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
