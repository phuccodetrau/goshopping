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
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;

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
            _avatarUrl = data['data']['avatarUrl'];
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
            _avatarUrl = data['data']['avatarUrl'];
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

      if (_imageFile != null) {
        await _uploadImage();
      }

      final requestBody = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
      };

      print('Sending request to: ${_url}/auth/user/update');
      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.put(
        Uri.parse('$_url/auth/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          await _refreshUserInfo();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật thông tin thành công')),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw Exception(data['message'] ?? 'Unknown error occurred');
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

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? selected = await _picker.pickImage(source: source);
      if (selected != null) {
        setState(() {
          _imageFile = File(selected.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra khi chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
        final String? token = await _secureStorage.read(key: "auth_token");
        
        var request = http.MultipartRequest(
            'POST', 
            Uri.parse('$_url/auth/user/upload-avatar')
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        
        // Lấy mime type từ đuôi file
        String mimeType = 'image/jpeg'; // default
        if (_imageFile!.path.toLowerCase().endsWith('.png')) {
            mimeType = 'image/png';
        } else if (_imageFile!.path.toLowerCase().endsWith('.gif')) {
            mimeType = 'image/gif';
        }
        
        print('Image file path: ${_imageFile!.path}');
        print('Image file size: ${await _imageFile!.length()}');
        print('Mime type: $mimeType');
        
        var file = await http.MultipartFile.fromPath(
            'avatar',
            _imageFile!.path,
            contentType: MediaType.parse(mimeType) // Thêm contentType
        );
        request.files.add(file);

        print('Sending avatar upload request to: ${request.url}');
        print('Headers: ${request.headers}');
        
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status'] == true && 
                jsonResponse['data'] != null) {
                
                final fullUrl = jsonResponse['data']['fullUrl'];
                final avatarUrl = jsonResponse['data']['avatarUrl'];
                final completeUrl = '$fullUrl$avatarUrl';
                
                setState(() {
                    _avatarUrl = completeUrl;
                });
                print('Avatar URL updated to: $_avatarUrl');
                
                if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
                    );
                }
            } else {
                throw Exception('Invalid response format: ${response.body}');
            }
        } else {
            throw Exception('Upload failed with status: ${response.statusCode}');
        }
    } catch (error) {
        print("Error uploading image: $error");
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Có lỗi xảy ra khi tải ảnh lên: $error')),
            );
        }
        rethrow;
    }
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _imageFile != null
              ? FileImage(_imageFile!) as ImageProvider
              : _avatarUrl != null
                  ? NetworkImage(_avatarUrl!)
                  : AssetImage('images/group.png') as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.green[700]),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Chọn từ thư viện'),
                          onTap: () {
                            Navigator.pop(context);
                            _selectImage(ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.photo_camera),
                          title: Text('Chụp ảnh'),
                          onTap: () {
                            Navigator.pop(context);
                            _selectImage(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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

