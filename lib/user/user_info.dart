import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_shopping/begin/splashScreen.dart';
import 'package:go_shopping/user/persion_infor_change.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  String email = "";
  String name = "";
  String _imageBase64 = "";
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
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
          });
        }
      }
    } catch (error) {
      print("Error fetching user info: $error");
    }
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
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (_imageBase64 == null || _imageBase64 == "") ? AssetImage('images/group.png') : MemoryImage(base64Decode(_imageBase64!)),
                ),
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
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.video_call, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.call, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Thống kê
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticCard('03', 'Nhóm đã tham gia', Colors.orange[300]!),
                _buildStatisticCard('5', 'Món mới', Colors.green[300]!),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Các tùy chọn
          Expanded(
            child: ListView(
              children: [
                _buildListTile(Icons.person, 'Chỉnh sửa thông tin cá nhân'),
                _buildListTile(Icons.upgrade, 'Nâng cấp phiên bản'),
                _buildListTile(Icons.star, 'Đánh giá'),
                _buildListTile(Icons.share, 'Chia sẻ với bạn bè'),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _secureStorage.deleteAll();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplashScreen(),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Xử lý khi chuyển đổi tab
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildStatisticCard(String number, String label, Color color) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        if (title == 'Chỉnh sửa thông tin cá nhân') {
          // Chờ kết quả từ màn hình cập nhật
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalInformationChangeScreen(),
            ),
          );
          
          // Nếu cập nhật thành công, refresh lại thông tin
          if (result == true) {
            await _initializeUserInfo();
          }
        }
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PersonalInfoScreen(),
  ));
}
