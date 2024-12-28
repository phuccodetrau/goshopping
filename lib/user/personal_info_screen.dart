import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class PersonalInformationChangeScreen extends StatefulWidget {
  const PersonalInformationChangeScreen({super.key});

  @override
  State<PersonalInformationChangeScreen> createState() => _PersonalInformationChangeScreenState();
}

class _PersonalInformationChangeScreenState extends State<PersonalInformationChangeScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String email = "";
  String name = "";
  String phoneNumber = "";
  bool _isLoading = false;

  File? _selectedImage;
  String _imageBase64 = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserInfo() async {
    final emailUser = await _secureStorage.read(key: "email") ?? '';
    setState(() {
      email = emailUser;
    });
    await _fetchUserInfo(emailUser);
  }

  Future<void> _fetchUserInfo(String email) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/auth/user/info?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            name = data['data']['name'] ?? '';
            phoneNumber = data['data']['phoneNumber'] ?? '';
            _imageBase64 = data['data']['avatar'] != null ? data['data']['avatar'] : "";
            _nameController.text = name;
            _emailController.text = email;
            _phoneController.text = phoneNumber;
          });
        }
      }
    } catch (error) {
      print("Error fetching user info: $error");
    }
  }

  Future<void> _refreshUserInfo() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/auth/user/info?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            name = data['data']['name'] ?? '';
            phoneNumber = data['data']['phoneNumber'] ?? '';
            _imageBase64 = data['data']['avatar'] != null ? data['data']['avatar'] : "";
          });
        }
      }
    } catch (error) {
      print("Error refreshing user info: $error");
    }
  }

  Future<void> _updateUserInfo() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Check if name exists
      if (_nameController.text != name) {
        final checkNameResponse = await http.get(
          Uri.parse('$_url/auth/user/check-name?name=${Uri.encodeComponent(_nameController.text)}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final checkNameData = jsonDecode(checkNameResponse.body);
        if (checkNameData['exists'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tên người dùng đã tồn tại, vui lòng chọn tên khác')),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final requestBody = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        "avatar": _imageBase64
      };

      final response = await http.put(
        Uri.parse('$_url/auth/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          await _refreshUserInfo();
          await _secureStorage.write(
              key: 'name',
              value: _nameController.text ?? ''
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật thông tin thành công')),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data['message']}')),
          );

        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (error) {
      print("Error updating user info: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra khi cập nhật thông tin: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageBase64 = base64Encode(File(image.path).readAsBytesSync()); // Chuyển ảnh thành base64
      });
    }
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage, // Chọn ảnh khi nhấn vào container
          child: CircleAvatar(
            radius: 40,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!) // Hiển thị ảnh đã chọn
                : _imageBase64 == "" ? AssetImage('images/person.png') as ImageProvider : MemoryImage(base64Decode(_imageBase64!)), // Placeholder
            backgroundColor: Colors.grey[200],
            child: _selectedImage == null
                ? Center(
              child: Icon(
                Icons.add_a_photo,
                color: Colors.grey,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.green[700],
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _buildAvatar(),
                      SizedBox(height: 8),
                      Text(
                        name.isNotEmpty ? name : 'Chưa cập nhật tên',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Chỉnh sửa thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Tên của bạn",
                          hintText: "Nhập tên của bạn",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        enabled: false, // Email không thể sửa
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại",
                          hintText: "Nhập số điện thoại",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateUserInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Lưu thông tin',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

