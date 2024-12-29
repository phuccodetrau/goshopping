import 'dart:convert';
import 'OTP_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Biến để kiểm tra email và trạng thái lỗi
  String URL=dotenv.env["ROOT_URL"]!+"/auth/user/sendverification-code";
  TextEditingController _emailController = TextEditingController();
  String? _errorText;
  bool _isEmailValid = false;
  bool _isLoading = false;

  Future<void> forgot_password()async{
    setState(() {
      _isLoading = true;
    });
    
    String email=_emailController.text;
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);
      print(responseData);
      
      setState(() {
        _isLoading = false;
      });
      
      if(responseData['status']==true){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: email,),
          ),
        );
      }else{
        setState(() {
          _errorText="Kiểm tra lại email của bạn! Thử lại sau vài giây!";
        });
      }
    } catch(err) {
      setState(() {
        _isLoading = false;
        _errorText="Kiểm tra lại email của bạn.";
      });
    }
  }
  // Hàm kiểm tra email hợp lệ
  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = 'Vui lòng nhập email.';
        _isEmailValid = false;
      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
        _errorText = 'Email không hợp lệ.';
        _isEmailValid = false;
      } else {
        _errorText = null;
        _isEmailValid = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn quên mật khẩu?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nhập tài khoản email đăng kí',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'hung.hd210399@sis.hust.edu.vn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                // Hiển thị thông báo lỗi nếu có
              ),
              onChanged: (value) {
                _validateEmail(value); // Kiểm tra email mỗi khi người dùng thay đổi
              },
            ),
            SizedBox(height: 10),
            if (_errorText != null)
              Text(
                _errorText!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                  onPressed: _isEmailValid ? () {
                    forgot_password();

                  } : null, // Nếu email không hợp lệ, nút sẽ không hoạt động
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEmailValid ? Colors.green[800] : Colors.grey, // Màu nút thay đổi tùy thuộc vào trạng thái email
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Tiếp theo',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
