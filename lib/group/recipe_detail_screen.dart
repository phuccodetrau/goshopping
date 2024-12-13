import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buy_old_food.dart';

class RecipeDetail extends StatefulWidget {
  final String groupId;
  final String email;
  final String recipeName;

  RecipeDetail({
    required this.groupId,
    required this.email,
    required this.recipeName,
  });

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  List<dynamic> ingredients = [];
  Map<String, Map<String, dynamic>> itemDetails = {};
  String recipeDescription = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchItemDetail(String foodName) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/item/getItemDetail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "foodName": foodName,
          "group": widget.groupId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 800) {
          setState(() {
            itemDetails[foodName] = data['data'];
          });
        }
      }
    } catch (error) {
      print("Error fetching item detail for $foodName: $error");
    }
  }

  Future<void> _fetchIngredients() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      print("Fetching ingredients for recipe: ${widget.recipeName}");
      
      final response = await http.post(
        Uri.parse('$_url/recipe/getAllFoodInReceipt'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "recipeName": widget.recipeName,
          "group": widget.groupId
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 711) {
          setState(() {
            ingredients = data['data']['list_item'];
            recipeDescription = data['data']['description'] ?? 'Không có hướng dẫn cách làm';
            isLoading = false;
          });
          
          for (var ingredient in ingredients) {
            await _fetchItemDetail(ingredient['foodName']);
          }
        }
      }
    } catch (error) {
      print("Error fetching ingredients: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildIngredientsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (ingredients.isEmpty) {
      return Center(
        child: Text('Không có nguyên liệu nào'),
      );
    }

    return Column(
      children: ingredients.map((ingredient) {
        final foodName = ingredient['foodName'];
        final itemDetail = itemDetails[foodName];
        final unitName = itemDetail?['unitName'] ?? 'đơn vị';
        final remaining = itemDetail?['totalAmount'] ?? 0;
        final bool isEnough = remaining >= ingredient['amount'];
        
        return IngredientCard(
          imagePath: 'images/group.png',
          name: foodName,
          quantity: '${ingredient['amount']} $unitName',
          remaining: 'Còn lại: $remaining $unitName',
          buttonLabel: isEnough ? 'Đủ nguyên liệu' : 'Mua thêm',
          buttonColor: isEnough ? Colors.green[100]! : Colors.red,
          textColor: isEnough ? Colors.green[700]! : Colors.white,
          onButtonPressed: isEnough ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyOldFood(
                  name: foodName,
                  unitName: unitName,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          'Thông tin chi tiết',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Phần chứa hình ảnh và thông tin món ăn
            Stack(
              children: [
                // Màu nền phía trên
                Container(
                  height: 120,
                  color: Colors.green[700],
                ),
                // Phần chứa hình ảnh và thông tin món ăn
                Column(
                  children: [
                    SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('images/group.png'), // Thay bằng đư���ng dẫn hình ảnh của bạn
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pad Thái',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('400 Kcal'),
                        SizedBox(width: 16),
                        Icon(Icons.timer, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('50 min'),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
            // Danh sách nguyên liệu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách nguyên liệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildIngredientsList(),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Colors.green[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Hướng dẫn cách làm
                  Text(
                    'Hướng dẫn cách làm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipeDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget cho mỗi nguyên liệu
class IngredientCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String quantity;
  final String remaining;
  final String buttonLabel;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback? onButtonPressed;

  IngredientCard({
    required this.imagePath,
    required this.name,
    required this.quantity,
    required this.remaining,
    required this.buttonLabel,
    required this.buttonColor,
    required this.textColor,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(quantity),
                  Text(
                    remaining,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RecipeDetail(
      groupId: 'groupId',
      email: 'email',
      recipeName: 'recipeName',
    ),
  ));
}
