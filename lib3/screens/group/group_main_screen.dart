import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../providers/group_provider.dart';
import '../recipe/recipe_list_screen.dart';
import '../food/food_list_screen.dart';
import '../meal_plan/meal_plan_screen.dart';
import '../user/user_info_screen.dart';
import 'list_task_screen.dart';
import 'add_member_screen.dart';
import '../statistics/statistics_screen.dart';

class GroupMainScreen extends StatefulWidget {
  final String groupName;
  final String adminName;
  final String groupId;

  const GroupMainScreen({
    Key? key,
    required this.groupName,
    required this.adminName,
    required this.groupId,
  }) : super(key: key);

  @override
  _GroupMainScreenState createState() => _GroupMainScreenState();
}

class _GroupMainScreenState extends State<GroupMainScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? email;
  String? id;
  String? name;
  String? token;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSecureValues();
  }

  Future<void> _loadSecureValues() async {
    try {
      token = await _secureStorage.read(key: 'auth_token');
      email = await _secureStorage.read(key: 'email');
      id = await _secureStorage.read(key: 'id');
      name = await _secureStorage.read(key: 'name');
      
      await Future.wait([
        _secureStorage.write(key: 'groupName', value: widget.groupName),
        _secureStorage.write(key: 'groupId', value: widget.groupId),
        _secureStorage.write(key: 'adminName', value: widget.adminName),
      ]);
    } catch (e) {
      debugPrint('Error loading secure values: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserInfoScreen()),
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
          icon: Icon(Icons.arrow_back, color: Colors.green[900]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontSize: 24,
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.green[900]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemberScreen(
                    groupName: widget.groupName,
                    groupId: widget.groupId,
                  ),
                ),
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
                  'assets/images/group.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const SectionTitle(title: "Quản lí thực phẩm"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FoodCard(
                    title: "Thực phẩm tủ lạnh",
                    description: "Quản lí số lượng các loại thực phẩm",
                    color: Colors.green[700]!,
                    iconPath: 'assets/images/group.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodListScreen(
                            categoryName: 'Tất cả',
                          ),
                        ),
                      );
                    },
                  ),
                  FoodCard(
                    title: "Danh sách món ăn",
                    description: "Quản lí danh sách thực đơn, có công thức kèm theo.",
                    color: Colors.orange[700]!,
                    iconPath: 'assets/images/group.png',
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
            const SectionTitle(title: "Hoạt động"),
            ActivityCard(
              title: "Kế hoạch nấu ăn",
              filesCount: 4,
              adminName: widget.adminName,
              adminAvatarPath: "assets/images/group.png",
              onTap: () {
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
              adminAvatarPath: "assets/images/group.png",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListTaskScreen(),
                  ),
                );
              },
            ),
            ActivityCard(
              title: "Thống kê",
              filesCount: 4,
              adminName: widget.adminName,
              adminAvatarPath: "assets/images/group.png",
              onTap: () {
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
        currentIndex: _selectedIndex,
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

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final String iconPath;
  final VoidCallback onTap;

  const FoodCard({
    Key? key,
    required this.title,
    required this.description,
    required this.color,
    required this.iconPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(iconPath, height: 50),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.cloud, size: 20, color: Colors.white),
                Text("20", style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final int filesCount;
  final String adminName;
  final String adminAvatarPath;
  final VoidCallback onTap;

  const ActivityCard({
    Key? key,
    required this.title,
    required this.filesCount,
    required this.adminName,
    required this.adminAvatarPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(adminAvatarPath),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$filesCount Files  Admin: $adminName",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}
