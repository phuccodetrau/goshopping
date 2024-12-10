import 'package:flutter/material.dart';

class MealDetailScreen extends StatefulWidget {
  final String groupId;
  final String email;

  MealDetailScreen({
    required this.groupId,
    required this.email,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  // Danh sách recipe mẫu (sau này sẽ lấy từ API)
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Canh rau ngót',
      'description': 'Rau ngót, thịt băm, hành, hạt nêm...',
    },
    {
      'name': 'Đậu hũ sốt cà',
      'description': 'Đậu hũ, thịt băm, hành, hạt nêm...',
    },
    {
      'name': 'Bún thịt nướng',
      'description': 'Bún, thịt băm, hành, hạt nêm...',
    },
  ];

  // Danh sách recipe đã chọn
  final List<Map<String, dynamic>> selectedRecipes = [];

  void _saveMealPlan() {
    // TODO: Implement save meal plan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu danh sách món ăn'),
        backgroundColor: Colors.green,
      ),
    );
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
                          'Bữa sáng',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Thứ 2, 20/11/2023',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.green[700]),
                      onPressed: () {
                        // TODO: Implement calendar
                      },
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
