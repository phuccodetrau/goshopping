import 'package:flutter/material.dart';
import '../home_screen/home_screen.dart';
import 'meal_plan_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../notification/notification_screen.dart';
import '../user/user_info.dart';
import 'package:flutter/animation.dart';

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
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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
    }}

  void _onSearchChanged() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      if (searchQuery.isEmpty) {
        filteredRecipes = recipes;
      } else {
        filteredRecipes = recipes.where((recipe) {
          final recipeName = recipe['name'].toString().toLowerCase();
          return recipeName.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      isLoading = true;
    });

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
            filteredRecipes = recipes;
          } else if (data['code'] == 708) {
            recipes = [];
            filteredRecipes = [];
            print("No recipes found for group: ${widget.groupId}");
          }
          isLoading = false;
        });
        print("Updated recipes list: $recipes");
      } else {
        throw Exception('Failed to fetch recipes');
      }
    } catch (error) {
      print("Error fetching recipes: $error");
      setState(() {
        recipes = [];
        filteredRecipes = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách công thức'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    return _fetchRecipes();
  }

  Future<void> _refreshScreen() async {
    await _fetchRecipes();  // Đợi fetch xong
    setState(() {});  // Force rebuild UI
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green[700],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải danh sách công thức...',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
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
                            controller: _searchController,
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
                    child: filteredRecipes.isEmpty 
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
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            return RecipeItemCard(
                              imagePath: 'images/food.png',
                              title: recipe['name'] ?? 'Không có tên',
                              description: recipe['description'] ?? 'Không có mô tả',
                              groupId: widget.groupId,
                              onDelete: () {
                                _refreshScreen();
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetail(
                                      recipeName: recipe['name'],
                                      groupId: widget.groupId,
                                      email: widget.email,
                                    ),
                                  ),
                                ).then((needRefresh) {
                                  if (needRefresh == true) {
                                    _fetchRecipes();
                                  }
                                });
                              },
                            );
                          },
                        ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
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
          
          if (shouldRefresh == true) {
            _fetchRecipes();
          }
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
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

// Widget cho từng món ăn trong danh sách
class RecipeItemCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;
  final String groupId;
  final VoidCallback? onDelete;

  RecipeItemCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
    required this.groupId,
    this.onDelete,
  });

  @override
  _RecipeItemCardState createState() => _RecipeItemCardState();
}

class _RecipeItemCardState extends State<RecipeItemCard> {
  String selectedMeal = '';

  Future<void> _deleteRecipe(BuildContext context, String recipeName, String groupId) async {
    try {
      final _secureStorage = FlutterSecureStorage();
      final String? token = await _secureStorage.read(key: "auth_token");
      final String _url = dotenv.env['ROOT_URL']!;

      final response = await http.post(
        Uri.parse('$_url/recipe/deleteRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "recipeName": recipeName,
          "group": groupId
        }),
      );

      final data = jsonDecode(response.body);

      if (data['code'] == 704) {
        Navigator.of(context).pop(); // Đóng dialog nếu còn mở
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Đã xóa công thức thành công'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Đảm bảo callback được gọi và đợi nó hoàn thành
        if (widget.onDelete != null) {
          await Future.delayed(Duration(milliseconds: 100)); // Đợi một chút để dialog đóng hoàn toàn
          widget.onDelete!();
        }
      } else {
        // Xóa thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(data['message'] ?? 'Không thể xóa công thức'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      print("Error deleting recipe: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi xóa công thức'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                // Hiển thị dialog xác nhận trước khi xóa
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Xác nhận xóa'),
                      content: Text('Bạn có chắc chắn muốn xóa công thức này?'),
                      actions: [
                        TextButton(
                          child: Text('Hủy'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            _deleteRecipe(context, widget.title, widget.groupId);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa công thức'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
