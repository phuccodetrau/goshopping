import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../repositories/food_repository.dart';
import '../../services/food_service.dart';
import 'buy_food_screen.dart';
import 'buy_old_food_screen.dart';
import 'update_food_screen.dart';
import 'package:go_shopping/main.dart';

class FoodListScreen extends StatefulWidget {
  final String categoryName;

  const FoodListScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> with RouteAware {
  final FoodRepository _foodRepository = FoodRepository(
    foodService: FoodService(),
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  String? email;
  String? id;
  String? name;
  String? token;
  String? groupName;
  String? groupId;
  String? adminName;
  String keyword = "";
  List<dynamic> listfood = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _loadSecureValues() async {
    try {
      token = await _storage.read(key: 'auth_token');
      email = await _storage.read(key: 'email');
      id = await _storage.read(key: 'id');
      name = await _storage.read(key: 'name');
      groupName = await _storage.read(key: 'groupName');
      groupId = await _storage.read(key: 'groupId');
      adminName = await _storage.read(key: 'adminName');
    } catch (e) {
      print('Error loading secure values: $e');
    }
  }

  Future<void> _fetchFood() async {
    try {
      if (groupId == null) return;
      
      final response = await _foodRepository.getFoodsByCategory(
        groupId: groupId!,
        categoryName: widget.categoryName,
      );
      setState(() {
        listfood = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _initializeData() async {
    await _loadSecureValues();
    await _fetchFood();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }
    _initializeData();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initializeData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Nguyên liệu, thành phần',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value;
                  // Implement search functionality if needed
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Danh sách nguyên liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: listfood.map((food) {
                  return FoodCard(
                    userName: name ?? '',
                    adminName: adminName ?? '',
                    imagePath: food["image"] ?? '',
                    name: food['name'] ?? '',
                    amount: food['totalAmount']?.toString() ?? '0',
                    unitName: food['unitName'] ?? '',
                    categoryName: widget.categoryName,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyFoodScreen(categoryName: widget.categoryName),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FoodCard extends StatefulWidget {
  final String userName;
  final String adminName;
  final String imagePath;
  final String name;
  final String amount;
  final String unitName;
  final String categoryName;

  const FoodCard({
    Key? key,
    required this.userName,
    required this.adminName,
    required this.imagePath,
    required this.name,
    required this.amount,
    required this.unitName,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.imagePath.isNotEmpty
              ? Image.memory(
                  base64Decode(widget.imagePath),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "images/fish.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        subtitle: Text("${widget.amount} ${widget.unitName}"),
        trailing: DropdownButton<String>(
          underline: const SizedBox(),
          icon: Icon(Icons.more_vert, color: Colors.green[700]),
          items: widget.userName == widget.adminName
              ? [
                  const DropdownMenuItem(value: 'Chỉnh sửa', child: Text('Chỉnh sửa')),
                  const DropdownMenuItem(value: 'Phân công', child: Text('Phân công')),
                ]
              : [
                  const DropdownMenuItem(value: 'Phân công', child: Text('Phân công')),
                ],
          onChanged: (value) {
            setState(() {
              isDropdownOpen = true;
            });
            if (value == 'Chỉnh sửa') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateFoodScreen(
                    name: widget.name,
                    categoryName: widget.categoryName,
                    unitName: widget.unitName,
                  ),
                ),
              );
            } else if (value == 'Phân công') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyOldFoodScreen(
                    foodName: widget.name,
                    unitName: widget.unitName,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
