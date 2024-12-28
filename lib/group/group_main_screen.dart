import 'dart:convert';

import 'package:flutter/material.dart';
import '../home_screen/home_screen.dart';
import 'group_list_user_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'recipe_list_screen.dart';
import 'fridge.dart';
import 'meal_plan_screen.dart';
import 'list_task.dart';
import 'add_group/add_member.dart';
import 'package:go_shopping/user/user_info.dart';
import 'package:go_shopping/statistics/statistics_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:go_shopping/statistics/statistics_screen.dart";
import 'package:go_shopping/notification/notification_screen.dart';
class GroupMainScreen extends StatefulWidget {
  String? imageBase64;
  final String groupName;
  final String adminName;
  final String groupId;

  GroupMainScreen({
    required this.groupName,
    required this.adminName,
    required this.groupId,
    required this.imageBase64
  });

  @override
  _GroupMainScreenState createState() => _GroupMainScreenState();
}

class _GroupMainScreenState extends State<GroupMainScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? email;
  String? id;
  String? name;
  String? token;
  int _selectedIndex = 0;
  String _imageBase64 = "";
  final ImagePicker _picker = ImagePicker();
  String URL = dotenv.env['ROOT_URL']!;

  Future<void> _loadSecureValues() async {
    try{
      token = await _secureStorage.read(key: 'auth_token');
      email = await _secureStorage.read(key: 'email');
      id = await _secureStorage.read(key: 'id');
      name = await _secureStorage.read(key: 'name');
      await _secureStorage.write(key: 'groupName', value: widget.groupName);
      await _secureStorage.write(key: 'groupId', value: widget.groupId);
      await _secureStorage.write(key: 'adminName', value: widget.adminName);
      print("name: $name");
      print("admin name: ${widget.adminName}");
    }catch(e){
      print('Error loading secure values: $e');
    }
  }
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Chuyển ảnh thành base64
      final base64String = base64Encode(File(image.path).readAsBytesSync());

      if (base64String.isNotEmpty) {
        print(1);

        // Chuẩn bị dữ liệu gửi API
        Map<String, String> body = {
          'groupId': widget.groupId,
          'avatar': base64String,
        };
        setState(() {
          _imageBase64 = base64String;
        });

        try {
          // Gọi API
          final response = await http.post(
            Uri.parse(URL + "/groups/update-group-image"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          );

          final responseData = jsonDecode(response.body);

          if (responseData["code"] == 700) {
            print("Thay ảnh đại diện nhóm thành công");
          } else {
            print("${responseData["message"]}");
          }

          // Cập nhật _imageBase64 khi API thành công
        } catch (error) {
          print("Lỗi khi gọi API: $error");
        }
      }
    }
  }

  void initState() {
    super.initState();
    _loadSecureValues();
  }

  void _onItemTapped(int index) {
    if (index == 0) {  // Home tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>HomeScreen()));
      }else if(index==1){
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>NotificationScreen()));
    }
    else if (index == 2) {  // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green[900],
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontSize: 24,
            color: Colors.green[900],
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: Colors.green[900],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMember(
                    imageBase64: widget.imageBase64,
                    groupName: widget.groupName,
                    groupId: widget.groupId,
                    adminName:widget.adminName,
                  ),
                ),
              );
            }
          ),
          IconButton(
            icon: Icon(
              Icons.people,
              color: Colors.green[900],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupListUserScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                widget.imageBase64 == "" || widget.imageBase64 == null ? Image.asset(
                  'images/group.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ) : _imageBase64 == "" ? Image.memory(base64Decode(widget.imageBase64!), height: 180, width: double.infinity, fit: BoxFit.cover) : Image.memory(base64Decode(_imageBase64), height: 180, width: double.infinity, fit: BoxFit.cover),
                IconButton(onPressed: (){
                  _pickImage();
                }, icon: Icon(
                  Icons.edit,
                  color: Colors.green[900],
                ))
              ],
            ),
            SectionTitle(title: "Quản lí thực phẩm"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FoodCard(
                    title: "Thực phẩm tủ lạnh",
                    description: "Quản lí số lượng các loại thực phẩm",
                    color: Colors.green[700]!,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Fridge(),
                        ),
                      );
                    },
                  ),
                  FoodCard(
                    title: "Danh sách món ăn",
                    description: "Quản lí danh sách thực đơn, có công thức kèm theo.",
                    color: Colors.orange[700]!,
                    onTap: () async {
                      final emailUser = await _secureStorage.read(key: "email") ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeListScreen(
                            groupId: widget.groupId,
                            email: emailUser,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SectionTitle(title: "Hoạt động"),
            ActivityCard(
              title: "Kế hoạch nấu ăn",
              filesCount: 4,
              adminName: widget.adminName,
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealPlanScreen(
                      groupId: widget.groupId,
                      email: email ?? '',
                    ),
                  ),
                );
              },
            ),
            ActivityCard(
              title: "Phân công",
              filesCount: 4,
              adminName: widget.adminName,
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListTask()),
                );
              },
            ),
            ActivityCard(
              title: "Thống kê",
              filesCount: 4,
              adminName: widget.adminName,
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      groupId: widget.groupId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(

        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class SectionTitle extends StatefulWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  _SectionTitleState createState() => _SectionTitleState();
}

class _SectionTitleState extends State<SectionTitle> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FoodCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap; // Thêm tham số onTap

  FoodCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap, // Khởi tạo onTap
  });

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Sử dụng onTap được truyền vào
      child: Container(
        height: 175,
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              widget.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(
              widget.description,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatefulWidget {
  final String title;
  final int filesCount;
  final String adminName;
  final VoidCallback onTap;

  ActivityCard({
    required this.title,
    required this.filesCount,
    required this.adminName,
    required this.onTap
  });

  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Admin: ${widget.adminName}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}
