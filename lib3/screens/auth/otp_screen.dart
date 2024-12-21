import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login_screen.dart';

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
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
      List.generate(4, (index) => FocusNode());
      
  bool isCodeNotReceived = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    for (var focusNode in otpFocusNodes) {
      focusNode.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    otpControllers.forEach((controller) => controller.dispose());
    otpFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        otpControllers[index + 1].clear();
        FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
      } else {
        otpFocusNodes[index].unfocus();
      }
    } else if (index > 0) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
    }
    setState(() {});

    if (otpControllers.every((controller) => controller.text.length == 1)) {
      _verifyOtp();
    }
  }

  Future<void> _onResendCode() async {
    setState(() {
      isCodeNotReceived = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.sendVerificationCode(widget.email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã OTP đã được gửi lại!")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hệ thống đang bị lỗi, vui lòng thử lại sau!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String otp = otpControllers.map((controller) => controller.text).join();

    try {
      final success = await userProvider.verifyOtp(widget.email, otp);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP xác minh thành công! Kiểm tra email để nhận mật khẩu mới"),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() {
          isError = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mã OTP không hợp lệ!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi hệ thống, vui lòng thử lại sau!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nhập mã OTP"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nhập mã 4 chữ số được gửi đến",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: otpFocusNodes[index].hasFocus
                            ? Colors.white
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: otpControllers[index],
                          focusNode: otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 24),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black, width: 2),
                            ),
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (value) => _onOtpChanged(index, value),
                          onTap: () {
                            if (otpControllers[index].text.isNotEmpty) {
                              otpControllers[index].clear();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                if (userProvider.isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
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
                      const Expanded(
                        child: Text(
                          "I didn't receive a code",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isError || userProvider.error != null)
                    Text(
                      userProvider.error ?? "Mã OTP bạn nhập không hợp lệ!",
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (isCodeNotReceived) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _onResendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Gửi lại mã OTP",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
} 