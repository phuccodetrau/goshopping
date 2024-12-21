import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/recipe_model.dart';
import '../../repositories/recipe_repository.dart';
import '../../services/recipe_service.dart';
import '../../repositories/item_repository.dart';
import '../../services/item_service.dart';

class AddRecipeScreen extends StatefulWidget {
  final String groupId;
  final String email;

  const AddRecipeScreen({
    super.key,
    required this.groupId,
    required this.email,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final Map<String, double> selectedFoods = {};
  List<Map<String, dynamic>> foods = [];
  bool _isLoading = false;
  String? _error;
  late final RecipeRepository _recipeRepository;
  late final ItemRepository _itemRepository;

  @override
  void initState() {
    super.initState();
    _recipeRepository = RecipeRepository(apiService: RecipeService());
    _itemRepository = ItemRepository(apiService: ItemService());
    _fetchFoods();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchFoods() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _itemRepository.getAllFood(token, widget.groupId);
      setState(() {
        foods = items.map((item) => {
          'name': item['name'],
          'categoryName': item['categoryName'],
          'unitName': item['unitName'],
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAmountDialog(String foodName, String unitName) {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập định lượng'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nhập số lượng ($unitName)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
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
            child: const Text('Xác nhận'),
          ),
        ],
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

  Widget _buildFoodCard(Map<String, dynamic> food) {
    final bool isSelected = selectedFoods.containsKey(food['name']);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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

  bool _validateData() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên món ăn'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập hướng dẫn cách làm'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một nguyên liệu'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _showSaveConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc chắn muốn lưu công thức này?'),
            const SizedBox(height: 16),
            Text(
              'Tên món: ${_nameController.text}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Số nguyên liệu: ${selectedFoods.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveRecipe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (!_validateData()) return;

    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final listItem = selectedFoods.entries.map((entry) => RecipeItem(
        foodName: entry.key,
        amount: entry.value.toInt(),
      )).toList();

      final recipe = Recipe(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        listItem: listItem,
        group: widget.groupId,
      );

      final success = await _recipeRepository.addRecipe(token, recipe);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo công thức thành công'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception('Không thể tạo công thức');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${_error}'),
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
        title: const Text(
          'Tạo công thức món ăn',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
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
                  const SizedBox(height: 8),
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

                  const SizedBox(height: 24),
                  Text(
                    'Hướng dẫn cách làm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
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

                  const SizedBox(height: 24),
                  if (selectedFoods.isNotEmpty) ...[
                    Text(
                      'Nguyên liệu đã chọn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...foods
                        .where((food) => selectedFoods.containsKey(food['name']))
                        .map((food) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
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
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            food['name'],
                                            style: const TextStyle(
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
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                    const Divider(height: 32, thickness: 1),
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm nguyên liệu',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Đã có lỗi xảy ra',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchFoods,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...foods
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_validateData()) {
                    _showSaveConfirmDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
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
