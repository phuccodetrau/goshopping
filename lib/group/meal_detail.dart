import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MealDetailScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final DateTime selectedDate;
  final String selectedMealTime;

  MealDetailScreen({
    required this.groupId,
    required this.email,
    required this.selectedDate,
    required this.selectedMealTime,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> selectedRecipes = [];
  bool isLoading = true;
  late DateTime selectedDate;
  late String selectedMealTime;
  String? existingMealPlanId;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    selectedMealTime = widget.selectedMealTime;
    _fetchMealPlan();
    _fetchAllRecipes();
  }

  Future<void> _fetchMealPlan() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      
      print("Fetching meal plan for date: $formattedDate");
      
      final response = await http.post(
        Uri.parse('$_url/meal/getMealPlanByDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "group": widget.groupId,
          "date": formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700 && data['data'] != null) {
          // Tìm meal plan cho bữa ăn đã chọn
          final mealPlan = data['data'].firstWhere(
            (meal) => meal['course'] == selectedMealTime,
            orElse: () => null,
          );

          if (mealPlan != null) {
            existingMealPlanId = mealPlan['_id'];
            if (mealPlan['listRecipe'] != null) {
              setState(() {
                selectedRecipes = List<Map<String, dynamic>>.from(
                  mealPlan['listRecipe'].map((recipe) => {
                    '_id': recipe['_id'],
                    'name': recipe['name'] ?? 'Không có tên',
                    'description': recipe['description'] ?? '',
                  }),
                );
              });
            }
          }
        }
      }
    } catch (error) {
      print("Error fetching meal plan: $error");
    }
  }

  Future<void> _fetchAllRecipes() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/recipe/getAllRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "group": widget.groupId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 709) {
          setState(() {
            recipes = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print("Error fetching recipes: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveMealPlan() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      
      // Lấy danh sách ID của các công thức đã chọn
      final recipeIds = selectedRecipes.map((recipe) => recipe['_id'].toString()).toList();
      
      print("Saving meal plan with recipe IDs: $recipeIds");
      
      final String endpoint = existingMealPlanId != null 
          ? '$_url/meal/updateMealPlan'
          : '$_url/meal/createMealPlan';

      final Map<String, dynamic> requestBody = {
        "date": formattedDate,
        "course": selectedMealTime,
        "recipe_ids": recipeIds,
        "group_id": widget.groupId,
      };

      if (existingMealPlanId != null) {
        requestBody["mealplan_id"] = existingMealPlanId;
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("Save response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã lưu danh sách món ăn'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lưu meal plan');
        }
      } else {
        throw Exception('Lỗi kết nối server');
      }
    } catch (error) {
      print("Error saving meal plan: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi lưu: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chi tiết bữa ăn',
          style: TextStyle(color: Colors.green[700], fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80, // Thêm padding bottom để không bị che bởi nút lưu
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thông tin bữa ăn và ngày
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedMealTime,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // 2. Danh sách món ăn đã chọn
                if (selectedRecipes.isNotEmpty) ...[
                  Text(
                    'Món ăn đã chọn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: selectedRecipes.map((recipe) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.restaurant_menu, color: Colors.green[700]),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    recipe['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  selectedRecipes.remove(recipe);
                                });
                              },
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  Divider(height: 32, thickness: 1),
                ],

                // 3. Thanh tìm kiếm
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
                            hintText: 'Tìm kiếm món ăn',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 4. Danh sách recipe có trong nhóm
                Text(
                  'Danh sách món ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    // Chỉ hiển thị những recipe chưa được chọn
                    itemCount: recipes.where((recipe) => !selectedRecipes.contains(recipe)).length,
                    itemBuilder: (context, index) {
                      // Lọc danh sách recipe chưa được chọn
                      final unselectedRecipes = recipes.where((recipe) => !selectedRecipes.contains(recipe)).toList();
                      final recipe = unselectedRecipes[index];
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.restaurant_menu, color: Colors.orange[700]),
                          ),
                          title: Text(
                            recipe['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            recipe['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.green[700]),
                            onPressed: () {
                              setState(() {
                                selectedRecipes.add(recipe);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Nút lưu cố định ở dưới cùng
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Hiển thị số lượng món đã chọn
                  Expanded(
                    child: Text(
                      '${selectedRecipes.length} món đã chọn',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  // Nút lưu
                  ElevatedButton(
                    onPressed: selectedRecipes.isEmpty ? null : _saveMealPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      disabledBackgroundColor: Colors.grey[400],
                      minimumSize: Size(120, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Lưu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget cho từng món ăn trong danh sách
class MealItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  MealItemCard({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.green[700]),
          onPressed: () {},
        ),
      ),
    );
  }
}
