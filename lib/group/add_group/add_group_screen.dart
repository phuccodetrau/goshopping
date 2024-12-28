import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'add_member.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddGroupScreen extends StatefulWidget {
  @override
  _AddGroupScreenState createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final int _maxChars = 75;
  final String _url = dotenv.env['ROOT_URL']!;
  List<Map<String, String>> _userEmails = [];
  late final String adminName;
  String _email = "";
  int _charCount = 0;
  String _imageBase64 = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeUserEmail();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  Future<String> getUserNameByEmail(String email) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/auth/user/get-user-name?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Get user name response: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['name'] != null) {
          return data['name'];
        }
      }
      throw Exception('Failed to get user name');
    } catch (error) {
      print("Error fetching user name: $error");
      return email; // Fallback to email if name fetch fails
    }
  }

  Future<void> _initializeUserEmail() async {
    final emailUser = await _secureStorage.read(key: "email") ?? '';
    print("User email: $emailUser");
    adminName=await _secureStorage.read(key: "name")??'';
    // Await the user name fetching process
    final userName = await getUserNameByEmail(emailUser);
    print("Fetched name for user: $userName");

    setState(() {
      _email = emailUser;
      _userEmails = [{
        "name": userName,
        "email": _email,
        "role": "admin"
      }];
    });
  }

  Future<void> _createGroup() async {
    final String groupName = _controller.text;

    try {
      final payload = {
        'name': groupName,
        'listUser': _userEmails,
        "avatar": _imageBase64
      };

      print("Payload being sent: ${jsonEncode(payload)}");

      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.post(
        Uri.parse("$_url/groups/create-group"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String groupId = responseData['data']['_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMember(
              imageBase64: _imageBase64,
              groupName: groupName,
              groupId: groupId,
              adminName: adminName
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo nhóm.')),
        );
      }
    } catch (error) {
      print("Error creating group: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tạo nhóm.')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageBase64 = base64Encode(File(image.path).readAsBytesSync()); // Chuyển ảnh thành base64
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _buildHeaderText(),
              SizedBox(height: 8),
              _buildSubHeaderText(),
              SizedBox(height: 32),
              _buildImageUploadSection(),
              SizedBox(height: 32),
              _buildGroupNameInput(),
              SizedBox(height: 16),
              _buildTermsText(),
              SizedBox(height: 16),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
        onPressed: () => Navigator.pop(context),
      ),

    );
  }

  Widget _buildHeaderText() {
    return Text(
      "Tùy chỉnh nhóm của bạn",
      style: TextStyle(
        fontSize: 22,
        color: Colors.green[900],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubHeaderText() {
    return Text(
      "Cá nhân hóa nhóm của bạn bằng cách đặt tên và thêm hình ảnh đại diện.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[700]),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () {
        // Add logic for image upload here
      },
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: _imageBase64 == "" ? Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_photo_alternate,
                size: 40,
                color: Colors.grey,
              ),
            ) : Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: MemoryImage(
                    base64Decode(_imageBase64), // Decode chuỗi Base64 thành Uint8List
                  ),
                  fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy Container
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text("Cập nhật hình ảnh", style: TextStyle(color: Colors.green[700])),
        ],
      ),
    );
  }

  Widget _buildGroupNameInput() {
    return TextField(
      controller: _controller,
      maxLength: _maxChars,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: "Tên nhóm",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        counterText: "$_charCount/$_maxChars",
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        text: "Khi tạo nhóm, nghĩa là bạn đã đồng ý với ",
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        children: [
          TextSpan(
            text: "Nguyên tắc cộng đồng",
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: " của Đi chợ tiện lợi."),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        if (_userEmails.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Danh sách người dùng trống!")),
          );
          return;
        }
        _createGroup();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      ),
      child: Text("Tiếp theo", style: TextStyle(fontSize: 16)),
    );
  }

}
