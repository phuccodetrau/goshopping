import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddRecipeScreen extends StatefulWidget {
  final String groupId;
  final String email;

  AddRecipeScreen({
    required this.groupId,
    required this.email,
  });

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  
  // Lưu trữ các food đã chọn và amount của chúng
  final Map<String, double> selectedFoods = {};
  // Controller cho amount input
  final TextEditingController _amountController = TextEditingController();
  // Danh sách food từ API
  List<Map<String, dynamic>> foods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      print("Fetching foods for groupId: ${widget.groupId}");
      
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

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 607 && data['data'] != null) {
          setState(() {
            foods = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
          print("Fetched foods: $foods");
        }
      }
    } catch (error) {
      print("Error fetching foods: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Hiển thị dialog nhập amount
  void _showAmountDialog(String foodName, String unitName) {
    _amountController.clear();
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
            // Icon thể hiện category
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
            // Thông tin food
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
            // Nút thêm/xóa
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

  // Kiểm tra dữ liệu trước khi lưu
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

  // Hiển thị dialog xác nhận lưu
  void _showSaveConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn lưu công thức này?'),
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
              _saveRecipe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Lưu công thức
  Future<void> _saveRecipe() async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      final String? token = await _secureStorage.read(key: "auth_token");
      
      // Chuẩn bị list_item từ selectedFoods
      final List<Map<String, dynamic>> listItem = selectedFoods.entries.map((entry) {
        return {
          "foodName": entry.key,
          "amount": entry.value
        };
      }).toList();

      // Gọi API tạo công thức
      final response = await http.post(
        Uri.parse('$_url/recipe/createRecipe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "description": _descriptionController.text.trim(),
          "list_item": listItem,
          "group": widget.groupId
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Đóng loading
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Tạo công thức thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Đợi một chút để người dùng thấy thông báo thành công
        await Future.delayed(Duration(milliseconds: 500));

        // Quay lại màn hình recipe list và yêu cầu refresh
        Navigator.pop(context, true); // Truyền true để báo hiệu cần refresh
      } else {
        throw Exception('Không thể tạo công thức');
      }
    } catch (error) {
      // Đóng loading nếu chưa đóng
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Hiển thị lỗi
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
          'Tạo công thức món ăn',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80), // Thêm padding để không bị che bởi nút lưu
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tên món ăn
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
                  // 2. Hướng dẫn cách làm
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
                  // 3. Danh sách nguyên liệu đã chọn
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

                  // Danh sách nguyên liệu có thể chọn
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
                  // Thanh tìm kiếm nguyên liệu
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
                  // Danh sách food cards chưa chọn
                  ...foods
                      .where((food) => !selectedFoods.containsKey(food['name']))
                      .map((food) => _buildFoodCard(food))
                      .toList(),
                ],
              ),
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
              child: ElevatedButton(
                onPressed: () {
                  if (_validateData()) {
                    _showSaveConfirmDialog();
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
                  'Lưu công thức',
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
