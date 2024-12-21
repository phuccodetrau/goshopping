import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/recipe_model.dart';
import '../../repositories/recipe_repository.dart';
import '../../services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final String recipeName;

  const RecipeDetailScreen({
    super.key,
    required this.groupId,
    required this.email,
    required this.recipeName,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, Map<String, dynamic>> itemDetails = {};
  Recipe? _recipe;
  bool _isLoading = false;
  String? _error;
  late final RecipeRepository _recipeRepository;

  @override
  void initState() {
    super.initState();
    _recipeRepository = RecipeRepository(apiService: RecipeService());
    _loadRecipeDetail();
  }

  Future<void> _loadRecipeDetail() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipe = await _recipeRepository.getRecipeDetail(token, widget.recipeName, widget.groupId);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });

      for (var item in recipe.listItem) {
        await _fetchItemDetail(item.foodName);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchItemDetail(String foodName) async {
    // TODO: Implement item detail fetching using ItemRepository
    // For now using mock data
    setState(() {
      itemDetails[foodName] = {
        'unitName': 'gram',
        'totalAmount': 100,
      };
    });
  }

  Widget _buildIngredientsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: _loadRecipeDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_recipe == null || _recipe!.listItem.isEmpty) {
      return const Center(
        child: Text('Không có nguyên liệu nào'),
      );
    }

    return Column(
      children: _recipe!.listItem.map((ingredient) {
        final foodName = ingredient.foodName;
        final itemDetail = itemDetails[foodName];
        final unitName = itemDetail?['unitName'] ?? 'đơn vị';
        final remaining = itemDetail?['totalAmount'] ?? 0;
        final bool isEnough = remaining >= ingredient.amount;

        return IngredientCard(
          imagePath: 'images/group.png',
          name: foodName,
          quantity: '${ingredient.amount} $unitName',
          remaining: 'Còn lại: $remaining $unitName',
          buttonLabel: isEnough ? 'Đủ nguyên liệu' : 'Mua thêm',
          buttonColor: isEnough ? Colors.green[100]! : Colors.red,
          textColor: isEnough ? Colors.green[700]! : Colors.white,
          onButtonPressed: isEnough
              ? null
              : () {
                  Navigator.pushNamed(
                    context,
                    '/buy-old-food',
                    arguments: {
                      'foodName': foodName,
                      'unitName': unitName,
                    },
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
        title: const Text(
          'Thông tin chi tiết',
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
                    const SizedBox(height: 16),
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('images/group.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _recipe?.name ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const Row(
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
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
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
                  const SizedBox(height: 8),
                  _buildIngredientsList(),
                  const SizedBox(height: 24),
                  Text(
                    'Hướng dẫn cách làm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recipe?.description ?? 'Không có hướng dẫn cách làm',
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

class IngredientCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String quantity;
  final String remaining;
  final String buttonLabel;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback? onButtonPressed;

  const IngredientCard({
    super.key,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(quantity),
                  Text(
                    remaining,
                    style: const TextStyle(color: Colors.red),
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
