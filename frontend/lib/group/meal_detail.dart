import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'recipe_detail_screen.dart';

class MealDetailScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final DateTime selectedDate;
  final String selectedMealTime;
  final bool isEditable;

  MealDetailScreen({
    required this.groupId,
    required this.email,
    required this.selectedDate,
    required this.selectedMealTime,
    required this.isEditable,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

// Thêm class để lưu thông tin chi tiết về recipe availability
class RecipeAvailabilityInfo {
  final bool canUse;
  final String message;
  final List<String> missingIngredients;

  RecipeAvailabilityInfo({
    required this.canUse,
    required this.message,
    this.missingIngredients = const [],
  });
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
  List<Map<String, dynamic>> temporaryRecipes = [];
  Map<String, RecipeAvailabilityInfo> recipeAvailability = {};

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
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận thêm món'),
          content: Text(
            'Bạn có chắc chắn muốn lưu thay đổi cho ${widget.selectedMealTime.toLowerCase()}?'
            '\n\nLưu ý: Sau khi lưu sẽ không thể chỉnh sửa nữa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Xác nhận'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700],
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      
      // Gộp danh sách recipe cũ và mới
      final allRecipeIds = [...selectedRecipes, ...temporaryRecipes]
          .map((recipe) => recipe['_id'].toString())
          .toList();
      
      final String endpoint = existingMealPlanId != null 
          ? '$_url/meal/updateMealPlan'
          : '$_url/meal/createMealPlan';

      final Map<String, dynamic> requestBody = {
        "date": formattedDate,
        "course": selectedMealTime,
        "recipe_ids": allRecipeIds,
        "group_id": widget.groupId,
      };

      if (existingMealPlanId != null) {
        requestBody["mealplan_id"] = existingMealPlanId;
      }

      // Lưu meal plan
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          // Sau khi lưu meal plan thành công, gọi useRecipe cho mỗi recipe mới
          bool allRecipesUsedSuccessfully = true;
          String errorMessage = '';

          for (var recipe in temporaryRecipes) {
            try {
              final useRecipeResponse = await http.post(
                Uri.parse('$_url/recipe/useRecipe'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  "recipeName": recipe['name'],
                  "group": widget.groupId,
                }),
              );

              final useRecipeData = jsonDecode(useRecipeResponse.body);
              if (useRecipeData['code'] != 714) {
                allRecipesUsedSuccessfully = false;
                errorMessage = useRecipeData['message'] ?? 'Lỗi khi sử dụng công thức';
                break;
              }
            } catch (error) {
              allRecipesUsedSuccessfully = false;
              errorMessage = error.toString();
              break;
            }
          }

          if (allRecipesUsedSuccessfully) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã lưu danh sách món ăn và cập nhật nguyên liệu'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else {
            // Nếu có lỗi khi sử dụng recipe, hiển thị thông báo
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi cập nhật nguyên liệu: $errorMessage'),
                backgroundColor: Colors.orange,
              ),
            );
            // Vẫn pop màn hình vì meal plan đã được lưu
            Navigator.pop(context, true);
          }
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lưu meal plan');
        }
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

  Widget _buildRecipeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị recipe đã có từ trước (không thể xóa)
        if (selectedRecipes.isNotEmpty) ...[
          Text(
            'Món ăn đã có',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: selectedRecipes.map((recipe) => _buildRecipeItem(
                recipe,
                canDelete: false,
              )).toList(),
            ),
          ),
        ],

        // Hiển thị recipe đang chỉnh sửa (có thể thêm/xóa)
        if (temporaryRecipes.isNotEmpty) ...[
          SizedBox(height: 16),
          Text(
            'Món ăn đang chỉnh sửa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: temporaryRecipes.map((recipe) => _buildRecipeItem(
                recipe,
                canDelete: true,
                onDelete: () {
                  setState(() {
                    temporaryRecipes.remove(recipe);
                  });
                },
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipeItem(Map<String, dynamic> recipe, {
    bool canDelete = false,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: canDelete ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: canDelete ? Colors.blue[700] : Colors.green[700],
            ),
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
          if (canDelete && onDelete != null)
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onDelete,
            )
          else
            Icon(Icons.lock, color: Colors.grey),
        ],
      ),
    );
  }

  // Thêm hàm kiểm tra recipe đã có trong meal plan chưa
  bool _isRecipeInMealPlan(Map<String, dynamic> recipe) {
    // Kiểm tra trong danh sách recipe đã có
    bool inSelectedRecipes = selectedRecipes.any((selected) => 
      selected['_id'] == recipe['_id']
    );
    
    // Kiểm tra trong danh sách recipe đang chỉnh sửa
    bool inTemporaryRecipes = temporaryRecipes.any((temp) => 
      temp['_id'] == recipe['_id']
    );

    return inSelectedRecipes || inTemporaryRecipes;
  }

  // Sửa lại hàm _checkRecipesAvailability
  Future<Map<String, RecipeAvailabilityInfo>> _checkRecipesAvailability(List<Map<String, dynamic>> recipes) async {
    final Map<String, RecipeAvailabilityInfo> availabilityMap = {};
    final String? token = await _secureStorage.read(key: "auth_token");

    for (var recipe in recipes) {
      try {
        final response = await http.post(
          Uri.parse('$_url/recipe/checkRecipeAvailability'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "recipeName": recipe['name'],
            "group": widget.groupId,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['code'] == 715) {
            final ingredients = data['data']['ingredients'] as List;
            final missingIngredients = ingredients
                .where((ing) => !ing['isAvailable'])
                .map((ing) {
                    final unit = ing['requiredUnit'] ?? ing['defaultUnit'] ?? 'đơn vị';
                    return '${ing['foodName']}: cần ${ing['requiredAmount']} $unit, có ${ing['availableAmount']} $unit';
                })
                .toList();

            availabilityMap[recipe['_id']] = RecipeAvailabilityInfo(
              canUse: data['data']['canUse'],
              message: data['data']['canUse'] 
                  ? 'Đủ nguyên liệu'
                  : 'Thiếu nguyên liệu',
              missingIngredients: missingIngredients,
            );
          }
        }
      } catch (error) {
        print("Error checking recipe availability: $error");
        availabilityMap[recipe['_id']] = RecipeAvailabilityInfo(
          canUse: false,
          message: 'Lỗi kiểm tra nguyên liệu',
        );
      }
    }
    return availabilityMap;
  }

  // Sửa lại widget hiển thị recipe
  Widget _buildRecipeCard(Map<String, dynamic> recipe, bool isAvailable) {
    final availability = recipeAvailability[recipe['_id']];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetail(
                groupId: widget.groupId,
                email: widget.email,
                recipeName: recipe['name'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: availability?.canUse == true ? Colors.orange[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: availability?.canUse == true ? Colors.orange[700] : Colors.grey,
                ),
              ),
              title: Text(
                recipe['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: availability?.canUse == true ? Colors.black : Colors.grey[600],
                ),
              ),
              subtitle: Text(
                recipe['description'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: availability?.canUse == true ? Colors.grey[600] : Colors.grey,
                ),
              ),
              trailing: availability?.canUse == true
                ? IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.green[700], size: 28),
                    onPressed: () {
                      setState(() {
                        temporaryRecipes.add(recipe);
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.orange[700]),
                    onPressed: () {
                      _showMissingIngredientsDialog(recipe['name'], availability!.missingIngredients);
                    },
                  ),
            ),
            if (availability?.canUse == false)
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: _buildUnavailableWarning("Không đủ nguyên liệu"),
              ),
          ],
        ),
      ),
    );
  }

  // Thêm hàm hiển thị dialog chi tiết nguyên liệu thiếu
  void _showMissingIngredientsDialog(String recipeName, List<String> missingIngredients) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết nguyên liệu thiếu'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Công thức: $recipeName',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ...missingIngredients.map((ingredient) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('• $ingredient'),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Thêm widget UnavailableRecipeWarning
  Widget _buildUnavailableWarning(String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            message,
            style: TextStyle(
              color: Colors.orange[900],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Sửa lại widget _buildAvailableRecipesList
  Widget _buildAvailableRecipesList() {
    // Lọc ra những recipe chưa có trong meal plan
    final availableRecipes = recipes.where((recipe) => 
      !_isRecipeInMealPlan(recipe)
    ).toList();

    if (availableRecipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Không còn món ăn nào có thể thêm',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, RecipeAvailabilityInfo>>(
      future: _checkRecipesAvailability(availableRecipes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        recipeAvailability = snapshot.data ?? {};

        // Tách thành 2 danh sách: đủ và thiếu nguyên liệu
        final availableWithIngredients = availableRecipes.where(
          (recipe) => recipeAvailability[recipe['_id']]?.canUse ?? false
        ).toList();

        final unavailableWithIngredients = availableRecipes.where(
          (recipe) => !(recipeAvailability[recipe['_id']]?.canUse ?? false)
        ).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (availableWithIngredients.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Món ăn có thể thêm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              ...availableWithIngredients.map((recipe) =>
                _buildRecipeCard(recipe, true)
              ),
            ],
            if (unavailableWithIngredients.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  'Món ăn thiếu nguyên liệu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
              ...unavailableWithIngredients.map((recipe) =>
                _buildRecipeCard(recipe, false)
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditable ? 'Chi tiết bữa ăn' : 'Xem bữa ăn',
          style: TextStyle(color: Colors.green[700], fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: widget.isEditable ? 100 : 16,
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

                  // Chỉ hiển thị phần tìm kiếm khi có thể chỉnh sửa
                  if (widget.isEditable) ...[
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
                  ],

                  // Hiển thị danh sách recipe đã chọn
                  _buildRecipeList(),

                  // Chỉ hiển thị danh sách món ăn có thể thêm khi có thể chỉnh sửa
                  if (widget.isEditable) ...[
                    Divider(height: 32, thickness: 1),
                    Text(
                      'Thêm món ăn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    // Thay thế ListView.builder cũ bằng widget mới
                    _buildAvailableRecipesList(),
                  ],
                ],
              ),
            ),
          ),
          // Nút lưu vẫn giữ nguyên
          if (widget.isEditable && temporaryRecipes.isNotEmpty)
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
                    Expanded(
                      child: Text(
                        '${temporaryRecipes.length} món mới',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveMealPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
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
