import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'add_member.dart';

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

  String _email = "";
  int _charCount = 0;

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
      final response = await http.get(
        Uri.parse('$_url/user/get-user-name-by-email?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Fetched user data: $data"); // Debug print

        if (data['status'] == true && data['name'] != null && data['name']['name'] != null) {
          return data['name']['name']; // Extract the name field correctly
        }
      }
    } catch (error) {
      print("Error fetching user name: $error");
    }
    return email.substring(0, 15); // Default if fetching fails
  }

  Future<void> _initializeUserEmail() async {
    final emailUser = await _secureStorage.read(key: "email") ?? '';
    print("User email: $emailUser");

    // Await the user name fetching process
    final userName = await getUserNameByEmail(emailUser);
    print("Fetched name for user: $userName"); // Debug print

    setState(() {
      _email = emailUser;
      _userEmails.add({
        "name": userName, // Use the fetched name or fallback
        "email": _email,
        "role": "admin"
      });
    });
  }

  Future<void> _createGroup() async {
    final String groupName = _controller.text;

    final response = await http.post(
      Uri.parse("$_url/groups/create-group"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': groupName,
        'listUser': _userEmails,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddMember()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo nhóm.')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
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
      actions: [
        TextButton(
          onPressed: () {},
          child: Text("Bỏ qua", style: TextStyle(color: Colors.green[800])),
        ),
      ],
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
      onTap: () {},
      child: Column(
        children: [
          Container(
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
      onPressed: _createGroup,
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
