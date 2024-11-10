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
  final String URL =dotenv.env['ROOT_URL']!+ "/auth/user";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isAgree = false;
  String? _responseMessage;

  bool get _isButtonEnabled =>
      _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _isAgree &&
          _passwordController.text == _confirmPasswordController.text;

  bool get _isPasswordMatch =>
      _confirmPasswordController.text.isEmpty ||
          _passwordController.text == _confirmPasswordController.text;

  bool get _isEmailValid => _emailController.text.isNotEmpty;
  bool get _isPasswordValid => _passwordController.text.isNotEmpty;
  bool get _isConfirmPasswordValid =>
      _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
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
    final String email = _emailController.text;
    final String password=_passwordController.text;
    print(email);
    print(password);
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email,'password':password}),
      );

      final responseData = jsonDecode(response.body);
      if(responseData['status']==true){
        final String token = responseData['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        await _secureStorage.write(key: 'email', value: responseData['user']['email']);
        await _secureStorage.write(key: 'id', value:  responseData['user']['_id'].toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }else{
        //TODO
      }
      print(responseData);
      setState(() {

      });
    } catch (e) {
      print(e);
      setState(() {

      });
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
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
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
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Confirm your password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
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
                    'Tiếp tục với Số điện thoại',
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
