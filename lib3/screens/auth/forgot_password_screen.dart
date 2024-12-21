import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorText;
  bool _isEmailValid = false;

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

  Future<void> _forgotPassword() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearError();

      final success = await userProvider.sendVerificationCode(_emailController.text);

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: _emailController.text,
              type: 'forgot_password',
            ),
          ),
        );
      } else {
        setState(() {
          _errorText = "Kiểm tra lại email của bạn! Thử lại sau vài giây!";
        });
      }
    } catch (err) {
      setState(() {
        _errorText = "Kiểm tra lại email của bạn.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
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
                const SizedBox(height: 20),
                Text(
                  'Nhập tài khoản email đăng kí',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
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
                  ),
                  onChanged: _validateEmail,
                ),
                const SizedBox(height: 10),
                if (_errorText != null || userProvider.error != null)
                  Text(
                    _errorText ?? userProvider.error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isEmailValid ? _forgotPassword : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEmailValid ? Colors.green[800] : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
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
          );
        },
      ),
    );
  }
} 