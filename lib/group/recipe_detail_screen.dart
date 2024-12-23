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
  String recipeName = '';
  Map<String, String> foodImages = {};
  bool canUseRecipe = false;
  String unavailableMessage = '';

  @override
  void initState() {
    super.initState();
    recipeName = widget.recipeName;
    _fetchIngredients();
    _checkRecipeAvailability();
  }

  Future<void> _fetchItemDetail(String foodName) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");

      // Lấy danh sách items
      final response = await http.post(
        Uri.parse('$_url/item/getSpecificItem'),
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
        if (data['code'] == 709) {
          // Lấy thông tin từ response mới
          final validItems = data['data']['validItems'] ?? [];
          final expiredItems = data['data']['expiredItems'] ?? [];
          final totalValidAmount = data['data']['totalValidAmount'] ?? 0;
          final totalExpiredAmount = data['data']['totalExpiredAmount'] ?? 0;

          // Lấy đơn vị từ item đầu tiên (nếu có)
          final defaultUnit = validItems.isNotEmpty 
              ? validItems[0]['unitName'] 
              : expiredItems.isNotEmpty 
                  ? expiredItems[0]['unitName'] 
                  : 'đơn vị';

          setState(() {
            itemDetails[foodName] = {
              'totalValidAmount': totalValidAmount,
              'totalExpiredAmount': totalExpiredAmount,
              'unitName': defaultUnit,
              'validItems': validItems,
              'expiredItems': expiredItems,
              'image': data['data']['image'],
            };
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
        body: jsonEncode(
            {"recipeName": widget.recipeName, "group": widget.groupId}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 711) {
          setState(() {
            ingredients = data['data']['list_item'];
            recipeDescription =
                data['data']['description'] ?? 'Không có hướng dẫn cách làm';
          });

          await Future.wait(
            ingredients.map((ingredient) => _fetchItemDetail(ingredient['foodName']))
          );
          
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print("Error fetching ingredients: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkRecipeAvailability() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/recipe/checkRecipeAvailability'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "recipeName": widget.recipeName,
          "group": widget.groupId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 715) {
          setState(() {
            canUseRecipe = data['data']['canUse'];
            if (!canUseRecipe) {
              final ingredients = data['data']['ingredients'] as List;
              final missingIngredients = ingredients.where((ing) => !ing['isAvailable']).map((ing) {
                return '${ing['foodName']}: cần ${ing['requiredAmount']} ${ing['requiredUnit']}, có ${ing['availableAmount']} ${ing['availableUnit']}';
              }).join('\n');
              unavailableMessage = 'Thiếu nguyên liệu:\n$missingIngredients';
            }
          });
        }
      }
    } catch (error) {
      print("Error checking recipe availability: $error");
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
        
        // Đảm bảo tất cả số lượng đều là double
        double requiredAmount = 0.0;
        try {
          requiredAmount = (ingredient['amount'] is int) 
              ? (ingredient['amount'] as int).toDouble()
              : ingredient['amount'] as double;
        } catch (e) {
          requiredAmount = 0.0;
        }
        
        final requiredUnit = ingredient['unitName'];

        // Lấy thông tin từ itemDetail và đảm bảo kiểu double
        final validItems = itemDetail?['validItems'] ?? [];
        final expiredItems = itemDetail?['expiredItems'] ?? [];
        
        // Chuyển đổi số lượng sang double một cách an toàn
        double totalValidAmount = 0.0;
        try {
          final rawValidAmount = itemDetail?['totalValidAmount'] ?? 0;
          totalValidAmount = (rawValidAmount is int) 
              ? rawValidAmount.toDouble() 
              : rawValidAmount as double;
        } catch (e) {
          totalValidAmount = 0.0;
        }

        double totalExpiredAmount = 0.0;
        try {
          final rawExpiredAmount = itemDetail?['totalExpiredAmount'] ?? 0;
          totalExpiredAmount = (rawExpiredAmount is int) 
              ? rawExpiredAmount.toDouble() 
              : rawExpiredAmount as double;
        } catch (e) {
          totalExpiredAmount = 0.0;
        }

        final defaultUnit = itemDetail?['unitName']; // Đơn vị mặc định từ Food
        final unitName = requiredUnit ?? defaultUnit ?? 'đơn vị';

        // Tính tổng số lượng có sẵn một cách an toàn
        final validItemsWithSameUnit = validItems.where((item) => 
          item['unitName'] == unitName
        ).toList();
        
        double totalValidAmountWithSameUnit = 0.0;
        for (var item in validItemsWithSameUnit) {
          try {
            final amount = item['amount'];
            if (amount is int) {
              totalValidAmountWithSameUnit += amount.toDouble();
            } else if (amount is double) {
              totalValidAmountWithSameUnit += amount;
            }
          } catch (e) {
            print('Error converting amount: $e');
          }
        }

        final bool isEnough = totalValidAmountWithSameUnit >= requiredAmount;
        final String? imageBase64 = itemDetail?['image'];

        return IngredientCard(
          imagePath: imageBase64 ?? '',
          name: foodName,
          quantity: '${requiredAmount.toStringAsFixed(1)} $unitName',
          remaining: 'Còn sử dụng được: ${totalValidAmountWithSameUnit.toStringAsFixed(1)} $unitName',
          buttonLabel: isEnough ? 'Đủ nguyên liệu' : 'Mua thêm',
          buttonColor: isEnough ? Colors.green[100]! : Colors.red,
          textColor: isEnough ? Colors.green[700]! : Colors.white,
          onButtonPressed: isEnough
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyOldFood(
                        foodName: foodName,
                        unitName: unitName,
                        amount: (requiredAmount - totalValidAmountWithSameUnit).abs().round(),
                        startDate: null,
                        endDate: null,
                        memberName: null,
                        memberEmail: null,
                        note: "",
                        id: null,
                        image: "",
                      ),
                    ),
                  );
                },
        );
      }).toList(),
    );
  }

  // Hàm hỗ trợ format ngày
  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green[700],
          ),
        ),
      );
    }

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
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  color: Colors.green[700],
                ),
                Column(
                  children: [
                    SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('images/group.png'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      recipeName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
            if (!isLoading) ...[
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canUseRecipe ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canUseRecipe ? Colors.green[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      canUseRecipe ? Icons.check_circle : Icons.warning,
                      color: canUseRecipe ? Colors.green[700] : Colors.orange[700],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        canUseRecipe 
                          ? 'Đủ nguyên liệu để thực hiện công thức này'
                          : unavailableMessage,
                        style: TextStyle(
                          color: canUseRecipe ? Colors.green[900] : Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Future<void> _useRecipe() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/recipe/useRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "recipeName": widget.recipeName,
          "group": widget.groupId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 714) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã sử dụng công thức thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchIngredients();
          _checkRecipeAvailability();
        } else {
          throw Exception(data['message']);
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    required this.textColor,
    required this.buttonColor,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Hình ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePath != "" 
                ? Image.memory(
                    base64Decode(imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ) 
                : Image.asset(
                    'images/fish.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
            ),
            SizedBox(width: 12),
            // Thông tin
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
                  SizedBox(height: 4),
                  Text(
                    'Cần: $quantity',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    remaining,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Nút
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
