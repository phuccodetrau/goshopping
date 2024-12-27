import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _passwordMismatchError;
  String? _passwordSameError;
  bool _isObscured2 = true;
  bool _isObscured1 = true;
  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi của trường mật khẩu mới và xác nhận mật khẩu
    _newPasswordController.addListener(_checkPasswordMatch);
    _confirmPasswordController.addListener(_checkPasswordMatch);
    _newPasswordController.addListener(_checkPasswordSame);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        _passwordMismatchError = "Mật khẩu mới và xác nhận mật khẩu không khớp!";
      } else {
        _passwordMismatchError = null; // Xóa lỗi nếu khớp
      }
    });
  }

  void _checkPasswordSame() {
    setState(() {
      if (_newPasswordController.text == _oldPasswordController.text) {
        _passwordSameError = "Mật khẩu mới không được trùng với mật khẩu cũ!";
      } else {
        _passwordSameError = null;
      }
    });
  }

  Future<void> _updatePassword() async {
    if (_passwordMismatchError != null || _passwordSameError != null) {
      // Không tiếp tục nếu có lỗi
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final String? email = await _secureStorage.read(key: "email");

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        "email": email,
        'oldPassword': _oldPasswordController.text,
        'newPassword': _newPasswordController.text,
      };

      final response = await http.post(
        Uri.parse('$_url/auth/update_password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật mật khẩu thành công')),
            );
            Navigator.pop(context, true);
          }
        } else {
          _showErrorDialog(data['message'] ?? 'Có lỗi không xác định xảy ra!');
        }
      } else {
        _showErrorDialog('Server trả về lỗi: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('Có lỗi xảy ra khi cập nhật mật khẩu: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _oldPasswordController,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu cũ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu mới",
                      hintText: "Nhập mật khẩu mới",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Thêm biểu tượng mắt vào phía sau trường mật khẩu
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured1
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured1= !_isObscured1;
                          });
                        },
                      ),
                    ),
                    obscureText: _isObscured1, // Đặt trạng thái ẩn/hiện
                  ),
                  // Thêm thông báo lỗi dưới ô mật khẩu mới
                  if (_passwordSameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordSameError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Xác nhận mật khẩu mới",
                      hintText: "Nhập lại mật khẩu mới",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Hiển thị lỗi mismatch nếu có
                      errorText: _passwordMismatchError,
                      // Thêm biểu tượng mắt vào phía sau trường nhập mật khẩu
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured2 ? Icons.visibility_off : Icons.visibility, // Tùy vào _isObscured
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // Chuyển đổi trạng thái của _isObscured
                          setState(() {
                            _isObscured2 = !_isObscured2;
                          });
                        },
                      ),
                    ),
                    obscureText: _isObscured2, // Sử dụng biến _isObscured để quyết định xem có ẩn mật khẩu hay không
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Lưu thông tin',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
