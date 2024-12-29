import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String URL = dotenv.env["ROOT_URL"]! + "/auth/user/sendverification-code";
  String submit_URL = dotenv.env["ROOT_URL"]! + "/auth/user/checkverification-code"; // API kiểm tra OTP
  // API kiểm tra OTP
  List<TextEditingController> otpControllers =
  List.generate(4, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes =
  List.generate(4, (index) => FocusNode());
  bool isLoading = false;
  bool isError = false;
  bool isCodeNotReceived = false; // Biến trạng thái để theo dõi việc người dùng chọn "Chưa nhận được mã"

  @override
  void initState() {
    super.initState();
    // Thêm listener cho mỗi FocusNode để cập nhật trạng thái focus
    for (var focusNode in otpFocusNodes) {
      focusNode.addListener(() {
        setState(() {}); // Cập nhật UI khi trạng thái focus thay đổi
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers và focus nodes để tránh memory leaks
    otpControllers.forEach((controller) => controller.dispose());
    otpFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    // Nếu người dùng nhập giá trị, chuyển focus sang ô tiếp theo
    if (value.isNotEmpty) {
      if (index < 3) {
        otpControllers[index+1].clear();
        FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
      } else {
        otpFocusNodes[index].unfocus(); // Unfocus ô cuối cùng
      }
    } else if (index > 0) {
      // Nếu xóa giá trị, chuyển focus sang ô trước đó
      FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
    }
    setState(() {}); // Cập nhật UI sau khi thay đổi giá trị

    // Kiểm tra nếu OTP đã nhập đủ 4 chữ số
    if (otpControllers.every((controller) => controller.text.length == 1)) {
      _verifyOtp(); // Gọi API kiểm tra OTP khi đủ 4 chữ số
    }
  }

  void _onResendCode() {
    // Xử lý khi người dùng chọn "Chưa nhận được mã"
    setState(() {
      isCodeNotReceived = true;
      // Gửi lại mã OTP hoặc thực hiện hành động khác
    });
    forgot_password();
  }

  Future<void> forgot_password() async {
    String email = widget.email;
    print(URL);
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      print(response);
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mã OTP đã được gửi lại!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: email),
          ),
        );
      } else {
        // Xử lý lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hệ thống đang bị lỗi, vui lòng thử lại sau!")),
        );
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hệ thống đang bị lỗi, vui lòng thử lại sau!")),
      );
    }
  }

  // Hàm gửi OTP để xác minh
  Future<void> _verifyOtp() async {
    String otp = otpControllers.map((controller) => controller.text).join();

    setState(() {
      isLoading = true; // Hiển thị loading
    });

    try {
      final response = await http.post(
        Uri.parse(submit_URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otp}),
      );

      final responseData = jsonDecode(response.body);
      print(responseData);
      setState(() {
        isLoading = false;
      });
      if (responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP xác minh thành công! Kiểm tra email để nhận mật khẩu mới")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        setState(() {
          isError = true; // Hiển thị lỗi nếu OTP không đúng
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mã OTP không hợp lệ!")),
        );
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      setState(() {
        isLoading = false; // Ẩn loading nếu có lỗi
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi hệ thống, vui lòng thử lại sau!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Nhập mã OTP"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nhập mã 4 chữ số được gửi đến",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            Text(
              widget.email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: otpFocusNodes[index].hasFocus
                        ? Colors.white // Màu trắng nếu ô đang được focus
                        : Colors.grey[300], // Màu xám cho các ô khác
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
                      style: TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black), // Viền đen mặc định
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black), // Viền đen khi ô không focus
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black, width: 2), // Viền đen dày hơn khi focus
                        ),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => _onOtpChanged(index, value),
                      onTap: () {
                        // Khi người dùng nhấn vào ô, xóa giá trị nếu ô trống
                        if (!otpControllers[index].text.isEmpty) {
                          otpControllers[index].clear();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            if (isLoading) ...[
              Center(child: CircularProgressIndicator()),
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
                  Expanded(
                    child: Text(
                      "I didn’t receive a code",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (isError)
                Text(
                  "Mã OTP bạn nhập không hợp lệ!",
                  style: TextStyle(color: Colors.red),
                ),
              if (isCodeNotReceived) ...[
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _onResendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Gửi lại mã OTP",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
