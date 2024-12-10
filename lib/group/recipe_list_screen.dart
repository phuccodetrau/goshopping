import 'package:flutter/material.dart';
import 'meal_plan_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecipeListScreen extends StatefulWidget {
  final String groupId;
  final String email;

  RecipeListScreen({
    required this.groupId,
    required this.email,
  });

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  List<dynamic> recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      print("Fetching recipes for groupId: ${widget.groupId}");
      
      final response = await http.post(
        Uri.parse('$_url/recipe/getAllRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "group": widget.groupId
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Decoded data: $data");
        
        setState(() {
          if (data['code'] == 709 && data['data'] != null) {
            recipes = data['data'];
          } else if (data['code'] == 708) {
            recipes = [];
            print("No recipes found for group: ${widget.groupId}");
          }
        });
        print("Updated recipes list: $recipes");
      }
    } catch (error) {
      print("Error fetching recipes: $error");
      setState(() {
        recipes = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Danh sách món ăn',
          style: TextStyle(color: Colors.green[700], fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant_menu, color: Colors.green[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealPlanScreen(
                    groupId: widget.groupId,
                    email: widget.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm trong danh sách món ăn',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Danh sách món ăn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: recipes.isEmpty 
                ? Center(
                    child: Text(
                      'Không có công thức nào',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeItemCard(
                        imagePath: 'images/group.png',
                        title: recipe['name'] ?? 'Không có tên',
                        description: recipe['description'] ?? 'Không có mô tả',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetail(),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipeScreen(
                groupId: widget.groupId,
                email: widget.email,
              ),
            ),
          );
          
          // Nếu nhận được tín hiệu refresh từ màn hình thêm recipe
          if (shouldRefresh == true) {
            _fetchRecipes(); // Gọi lại API để lấy danh sách mới
          }
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}

// Widget cho từng món ăn trong danh sách
class RecipeItemCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  RecipeItemCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap
  });

  @override
  _RecipeItemCardState createState() => _RecipeItemCardState();
}

class _RecipeItemCardState extends State<RecipeItemCard> {
  String selectedMeal = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              widget.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(widget.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedMeal.isNotEmpty)
                Text(
                  selectedMeal,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
