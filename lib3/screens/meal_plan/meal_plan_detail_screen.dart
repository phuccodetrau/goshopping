import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/meal_plan_repository.dart';
import '../../services/meal_plan_service.dart';
import '../../repositories/recipe_repository.dart';
import '../../services/recipe_service.dart';

class MealPlanDetailScreen extends StatefulWidget {
  final String groupId;
  final String email;
  final DateTime selectedDate;
  final String selectedMealTime;

  const MealPlanDetailScreen({
    super.key,
    required this.groupId,
    required this.email,
    required this.selectedDate,
    required this.selectedMealTime,
  });

  @override
  State<MealPlanDetailScreen> createState() => _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends State<MealPlanDetailScreen> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> selectedRecipes = [];
  bool _isLoading = false;
  String? _error;
  String? _existingMealPlanId;
  late final MealPlanRepository _mealPlanRepository;
  late final RecipeRepository _recipeRepository;

  @override
  void initState() {
    super.initState();
    _mealPlanRepository = MealPlanRepository(apiService: MealPlanService());
    _recipeRepository = RecipeRepository(apiService: RecipeService());
    _fetchMealPlan();
    _fetchAllRecipes();
  }

  Future<void> _fetchMealPlan() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    try {
      final formattedDate = "${widget.selectedDate.toLocal()}".split(' ')[0];
      _existingMealPlanId = await _mealPlanRepository.getMealPlanId(
        token,
        widget.groupId,
        formattedDate,
        widget.selectedMealTime,
      );

      final meals = await _mealPlanRepository.getMealPlanByDate(
        token,
        widget.groupId,
        formattedDate,
      );

      setState(() {
        selectedRecipes = List<Map<String, dynamic>>.from(
          meals[widget.selectedMealTime] ?? [],
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchAllRecipes() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allRecipes = await _recipeRepository.getAllRecipes(token, widget.groupId);
      setState(() {
        recipes = allRecipes.map((recipe) => recipe.toJson()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMealPlan() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final formattedDate = "${widget.selectedDate.toLocal()}".split(' ')[0];
      final recipeIds = selectedRecipes.map((recipe) => recipe['_id'].toString()).toList();

      final success = await _mealPlanRepository.saveMealPlan(
        token,
        widget.groupId,
        formattedDate,
        widget.selectedMealTime,
        recipeIds,
        mealPlanId: _existingMealPlanId,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu danh sách món ăn'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Không thể lưu meal plan');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi lưu: ${_error}'),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedMealTime,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
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

                Text(
                  'Danh sách món ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
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
                          onPressed: _fetchAllRecipes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: recipes.where((recipe) => !selectedRecipes.contains(recipe)).length,
                      itemBuilder: (context, index) {
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
                      '${selectedRecipes.length} món đã chọn',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedRecipes.isEmpty || _isLoading ? null : _saveMealPlan,
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
