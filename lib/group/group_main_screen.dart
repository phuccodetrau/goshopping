import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'recipe_list_screen.dart';
import 'fridge.dart';
import 'meal_plan_screen.dart';

class GroupMainScreen extends StatefulWidget {
  final String groupName;
  final String adminName;
  final String groupId;


  GroupMainScreen({
    required this.groupName,
    required this.adminName,
    required this.groupId
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
  Future<void> _loadSecureValues() async {
    try{
      token = await _secureStorage.read(key: 'auth_token');
      email = await _secureStorage.read(key: 'email');
      id = await _secureStorage.read(key: 'id');
      name = await _secureStorage.read(key: 'name');
      await _secureStorage.write(key: 'groupName', value: widget.groupName);
      await _secureStorage.write(key: 'groupId', value: widget.groupId);
      await _secureStorage.write(key: 'adminName', value: widget.adminName);
    }catch(e){
      print('Error loading secure values: $e');
    }
  }
  void initState() {
    super.initState();
    _loadSecureValues();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.person_add), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              print('email: $email');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
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
                Image.asset(
                  'images/group.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white),
                      Text(
                        widget.groupName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Icon(Icons.edit, color: Colors.white),
                ),
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
                    iconPath: 'images/group.png',
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
                    title: "Món ăn theo ngày",
                    description: "Quản lí từng bữa ăn dễ dàng, có công thức kèm theo.",
                    color: Colors.orange[700]!,
                    iconPath: 'images/group.png',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeListScreen(),
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
              adminAvatarPath: "images/group.png",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealPlanScreen()),
                );
              },
            ),
          ],
        ),
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
  final String iconPath;
  final VoidCallback onTap; // Thêm tham số onTap

  FoodCard({
    required this.title,
    required this.description,
    required this.color,
    required this.iconPath,
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
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(widget.iconPath, height: 50),
            ),
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
                Icon(Icons.cloud, size: 20),
                Text("20"),
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
  final String adminAvatarPath;
  final VoidCallback onTap;

  ActivityCard({
    required this.title,
    required this.filesCount,
    required this.adminName,
    required this.adminAvatarPath,
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
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(widget.adminAvatarPath),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${widget.filesCount} Files  Admin: ${widget.adminName}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}
