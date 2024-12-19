import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String type;

  const OtpScreen({
    super.key, 
    required this.email,
    required this.type,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(4, (index) => FocusNode());
  bool isCodeNotReceived = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    for (var focusNode in otpFocusNodes) {
      focusNode.addListener(() {
        setState(() {});
      });
    }
    
    // Tự động hiện bàn phím cho ô đầu tiên
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(otpFocusNodes[0]);
    });
  }

  @override
  void dispose() {
    otpControllers.forEach((controller) => controller.dispose());
    otpFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  String get _otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(int index) {
    setState(() {
      errorText = null;
    });

    if (otpControllers[index].text.length == 1 && index < 3) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 4) {
      setState(() {
        errorText = 'Vui lòng nhập đủ 4 số';
      });
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearError();

      final success = await userProvider.verifyOtp(widget.email, _otpCode);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP xác minh thành công! Kiểm tra email để nhận mật khẩu mới'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển về màn hình đăng nhập
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, // Xóa tất cả các màn hình trong stack
        );
      } else {
        setState(() {
          errorText = userProvider.error ?? 'Mã OTP không hợp lệ';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorText = 'Có lỗi xảy ra: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.clearError();

    final success = await userProvider.sendVerificationCode(widget.email);

    if (!mounted) return;

    if (success) {
      setState(() {
        isCodeNotReceived = false;
        errorText = null;
        // Reset các ô OTP
        otpControllers.forEach((controller) => controller.clear());
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã xác thực đã được gửi lại'),
          backgroundColor: Colors.green,
        ),
      );

      // Focus vào ô đầu tiên
      FocusScope.of(context).requestFocus(otpFocusNodes[0]);
    } else {
      setState(() {
        errorText = userProvider.error ?? 'Không thể gửi lại mã';
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
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác thực OTP',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhập mã xác thực',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mã xác thực đã được gửi đến email ${widget.email}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: 50,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: otpFocusNodes[index].hasFocus
                              ? Colors.green[50]
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        onChanged: (value) => _onOtpChanged(index),
                      ),
                    ),
                  ),
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: isCodeNotReceived,
                      onChanged: (value) {
                        setState(() {
                          isCodeNotReceived = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        "Tôi chưa nhận được mã",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                if (isCodeNotReceived) ...[
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _resendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        "Gửi lại mã OTP",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _otpCode.length == 4 ? _verifyOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _otpCode.length == 4 ? Colors.green[700] : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
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