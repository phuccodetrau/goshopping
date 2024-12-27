import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditRecipeScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final String recipeName;
  final String description;
  final List<dynamic> ingredients;

  EditRecipeScreen({
    required this.groupId,
    required this.email,
    required this.recipeName,
    required this.description,
    required this.ingredients,
  });

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchFoodController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  
  final Map<String, double> selectedFoods = {};
  final TextEditingController _amountController = TextEditingController();
  List<Map<String, dynamic>> foods = [];
  List<Map<String, dynamic>> filteredFoods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.recipeName;
    _descriptionController.text = widget.description;
    // Khởi tạo selectedFoods từ ingredients hiện tại
    for (var ingredient in widget.ingredients) {
      selectedFoods[ingredient['foodName']] = ingredient['amount'].toDouble();
    }
    _fetchFoods();
    _searchFoodController.addListener(_onSearchFoodChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _searchFoodController.dispose();
    super.dispose();
  }

  void _onSearchFoodChanged() {
    final searchQuery = _searchFoodController.text.toLowerCase();
    setState(() {
      if (searchQuery.isEmpty) {
        filteredFoods = foods;
      } else {
        filteredFoods = foods.where((food) {
          final foodName = food['name'].toString().toLowerCase();
          return foodName.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _fetchFoods() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      final response = await http.post(
        Uri.parse('$_url/food/getAllFood'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': widget.groupId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 607 && data['data'] != null) {
          setState(() {
            foods = List<Map<String, dynamic>>.from(data['data']);
            filteredFoods = foods;
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print("Error fetching foods: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAmountDialog(String foodName, String unitName) {
    _amountController.text = selectedFoods[foodName]?.toString() ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập định lượng'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nhập số lượng ($unitName)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (_amountController.text.isNotEmpty) {
                setState(() {
                  selectedFoods[foodName] = double.parse(_amountController.text);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    final bool isSelected = selectedFoods.containsKey(food['name']);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(food['categoryName']),
                  color: Colors.green[700],
                  size: 30,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    food['categoryName'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isSelected ? Icons.remove_circle : Icons.add_circle,
                color: isSelected ? Colors.red : Colors.green[700],
              ),
              onPressed: () {
                if (isSelected) {
                  setState(() {
                    selectedFoods.remove(food['name']);
                  });
                } else {
                  _showAmountDialog(food['name'], food['unitName']);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'thịt':
        return Icons.restaurant_menu;
      case 'rau':
        return Icons.eco;
      case 'sua':
        return Icons.local_drink;
      case 'gia vi':
        return Icons.spa;
      case 'ngu coc':
        return Icons.grain;
      default:
        return Icons.food_bank;
    }
  }

  bool _validateData() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập tên món ăn'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập hướng dẫn cách làm'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ít nhất một nguyên liệu'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _showUpdateConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn cập nhật công thức này?'),
            SizedBox(height: 16),
            Text(
              'Tên món: ${_nameController.text}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Số nguyên liệu: ${selectedFoods.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateRecipe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRecipe() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      final String? token = await _secureStorage.read(key: "auth_token");
      
      final List<Map<String, dynamic>> listItem = selectedFoods.entries.map((entry) {
        return {
          "foodName": entry.key,
          "amount": entry.value
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$_url/recipe/updateRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "recipeName": widget.recipeName,
          "group": widget.groupId,
          "newData": {
            "name": _nameController.text.trim(),
            "description": _descriptionController.text.trim(),
            "list_item": listItem
          }
        }),
      );

      Navigator.pop(context); // Đóng loading dialog

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 702) { // Mã thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật công thức thành công'),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(Duration(milliseconds: 500));
          Navigator.pop(context, {
            'newName': _nameController.text.trim(),
            'needRefresh': true
          });
        } else if (data['code'] == 704) { // Trùng tên recipe
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tên công thức mới đã tồn tại trong nhóm này'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Đổi tên',
                textColor: Colors.white,
                onPressed: () {
                  // Focus vào trường tên
                  FocusScope.of(context).requestFocus(
                    FocusNode()
                  );
                  _nameController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _nameController.text.length
                  );
                },
              ),
            ),
          );
        } else if (data['code'] == 703) { // Không tìm thấy recipe
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không tìm thấy công thức để cập nhật'),
              backgroundColor: Colors.red,
            ),
          );
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.pop(context);
        } else if (data['code'] == 701) { // Danh sách nguyên liệu trống
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Danh sách nguyên liệu không được để trống'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Có lỗi xảy ra khi cập nhật');
        }
      }
    } catch (error) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Đóng loading dialog nếu có lỗi
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          'Chỉnh sửa công thức',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tên món ăn',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên món ăn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),

                  SizedBox(height: 24),
                  Text(
                    'Hướng dẫn cách làm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Thông tin chi tiết cách làm cụ thể',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),

                  SizedBox(height: 24),
                  if (selectedFoods.isNotEmpty) ...[
                    Text(
                      'Nguyên liệu đã chọn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    ...foods
                        .where((food) => selectedFoods.containsKey(food['name']))
                        .map((food) => Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              color: Colors.green[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
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
                                      child: Center(
                                        child: Icon(
                                          _getCategoryIcon(food['categoryName']),
                                          color: Colors.green[700],
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            food['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${selectedFoods[food['name']]} ${food['unitName']}',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.green[700]),
                                      onPressed: () => _showAmountDialog(food['name'], food['unitName']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          selectedFoods.remove(food['name']);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                    Divider(height: 32, thickness: 1),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thêm nguyên liệu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (selectedFoods.isNotEmpty)
                        Text(
                          '${selectedFoods.length} đã chọn',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchFoodController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm nguyên liệu',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ...filteredFoods
                      .where((food) => !selectedFoods.containsKey(food['name']))
                      .map((food) => _buildFoodCard(food))
                      .toList(),
                ],
              ),
            ),
          ),
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
              child: ElevatedButton(
                onPressed: () {
                  if (_validateData()) {
                    _showUpdateConfirmDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cập nhật công thức',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 