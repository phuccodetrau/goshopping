import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_shopping/home_screen/home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'forgot_password_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String URL=dotenv.env['ROOT_URL']!+"/auth/user/login";
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isError = false;
  bool isEmailEmpty = false;
  bool isPasswordEmpty = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkIfInputIsFilled);
    passwordController.addListener(_checkIfInputIsFilled);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isInputValid {
    return emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

  void _checkIfInputIsFilled() {
    setState(() {
      isEmailEmpty = emailController.text.isEmpty;
      isPasswordEmpty = passwordController.text.isEmpty;
    });
  }

  Future<void> _onLoginPressed() async{
    final String email=emailController.text;
    final String password=passwordController.text;
    print(email);
    print(password);
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email,'password':password}),
      );

      final responseData = jsonDecode(response.body);
      print(responseData);
      if(responseData['status']==true){
        final String token = responseData['token'];

        await _secureStorage.write(key: 'auth_token', value: token);
        await _secureStorage.write(key: 'email', value: responseData['user']['email']);
        await _secureStorage.write(key: 'id', value:  responseData['user']['_id'].toString());
        await _secureStorage.write(key:"name",value:responseData['user']['name'].toString());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }else{
        //TODO
        setState(() {
          isError=true;
        });
      }

    } catch (e) {
      print(e);
      setState(() {
          isError=true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Xử lý quay lại
          },
        ),
        title: Text(
          "Chào mừng bạn trở lại!",
          style: TextStyle(
            fontSize: 24,
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông Tin Tài Khoản",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            // Trường nhập email
            TextField(
              controller: emailController,

              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            if (isEmailEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Vui lòng nhập email",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(height: 16),

            // Trường nhập mật khẩu
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                labelStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            if (isPasswordEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Vui lòng nhập mật khẩu",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            if (isError)
              Text(
                "Mật khẩu chưa chính xác, vui lòng thử lại!",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: isInputValid ? _onLoginPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isInputValid ? Colors.green[700] : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Center(
                child: Text(
                  "Đăng nhập",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}