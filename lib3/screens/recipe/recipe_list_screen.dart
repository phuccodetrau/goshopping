import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/recipe_model.dart';
import '../../repositories/recipe_repository.dart';
import '../../services/recipe_service.dart';

class RecipeListScreen extends StatefulWidget {
  final String groupId;
  final String email;

  const RecipeListScreen({
    super.key,
    required this.groupId,
    required this.email,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = false;
  String? _error;
  late final RecipeRepository _recipeRepository;

  @override
  void initState() {
    super.initState();
    _recipeRepository = RecipeRepository(apiService: RecipeService());
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipes = await _recipeRepository.getAllRecipes(token, widget.groupId);
      setState(() {
        _recipes = recipes;
        _updateFilteredRecipes('');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateFilteredRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = _recipes;
      } else {
        _filteredRecipes = _recipes
            .where((recipe) =>
                recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                (recipe.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                  Navigator.pushNamed(
                    context,
                    '/meal-plan',
                    arguments: {
                      'groupId': widget.groupId,
                      'email': widget.email,
                    },
                  );
                },
              ),
            ],
          ),
          body: _error != null
              ? Center(
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
                        onPressed: _loadRecipes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Tìm trong danh sách món ăn',
                                  border: InputBorder.none,
                                ),
                                onChanged: _updateFilteredRecipes,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Danh sách món ăn',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _filteredRecipes.isEmpty
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
                                itemCount: _filteredRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = _filteredRecipes[index];
                                  return RecipeItemCard(
                                    imagePath: 'images/group.png',
                                    title: recipe.name,
                                    description: recipe.description ?? 'Không có mô tả',
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/recipe-detail',
                                        arguments: {
                                          'recipeName': recipe.name,
                                          'groupId': widget.groupId,
                                          'email': widget.email,
                                        },
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
              final result = await Navigator.pushNamed(
                context,
                '/add-recipe',
                arguments: {
                  'groupId': widget.groupId,
                  'email': widget.email,
                },
              );
              if (result == true) {
                _loadRecipes();
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

class RecipeItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  const RecipeItemCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
        ),
      ),
    );
  }
}
