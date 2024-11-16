import 'package:flutter/material.dart';
import 'meal_plan_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Danh sách món ăn',
          style: TextStyle(color: Colors.green[700], fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[700]),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant_menu, color: Colors.green[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealPlanScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.green[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
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
                        hintText: 'Tìm trong danh sách món ăn',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Gợi ý món ăn hôm nay
            Text(
              'Gợi ý món ăn hôm nay',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bạn có muốn ăn nhẹ nhàng?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            // Hình ảnh gợi ý món ăn
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  RecipeSuggestionImage('images/group.png'),
                  RecipeSuggestionImage('images/group.png'),
                  RecipeSuggestionImage('images/group.png'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Danh sách món ăn
            Text(
              'Danh sách món ăn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            // Bọc ListView trong Expanded để đảm bảo chiều cao giới hạn
            Expanded(
              child: ListView(
                children: [
                  RecipeItemCard(
                    imagePath: 'images/group.png',
                    title: 'Canh rau ngót',
                    description: 'Rau ngót, thịt băm, hành, hạt nêm...',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetail(),
                        ),
                      );
                    },
                  ),
                  RecipeItemCard(
                    imagePath: 'images/group.png',
                    title: 'Đậu hũ sốt cà',
                    description: 'Đậu hũ, thịt băm, hành, hạt nêm...',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetail(),
                        ),
                      );
                    },
                  ),
                  RecipeItemCard(
                    imagePath: 'images/group.png',
                    title: 'Bún thịt nướng',
                    description: 'Bún, thịt băm, hành, hạt nêm...',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetail(),
                        ),
                      );
                    },
                  ),
                  RecipeItemCard(
                    imagePath: 'images/group.png',
                    title: 'Nem rán',
                    description: 'Thịt băm, hành, nấm, cà rốt...',
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetail(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipeScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}

// Widget cho phần gợi ý hình ảnh món ăn
class RecipeSuggestionImage extends StatefulWidget {
  final String imagePath;

  RecipeSuggestionImage(this.imagePath);

  @override
  _RecipeSuggestionImageState createState() => _RecipeSuggestionImageState();
}

class _RecipeSuggestionImageState extends State<RecipeSuggestionImage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          widget.imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Widget cho từng món ăn trong danh sách
class RecipeItemCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  RecipeItemCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap
  });

  @override
  _RecipeItemCardState createState() => _RecipeItemCardState();
}

class _RecipeItemCardState extends State<RecipeItemCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              widget.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(widget.description),
          trailing: DropdownButton<String>(
            underline: SizedBox(),
            icon: Icon(Icons.more_vert, color: Colors.green[700]),
            items: [
              DropdownMenuItem(value: 'Bữa sáng', child: Text('Bữa sáng')),
              DropdownMenuItem(value: 'Bữa trưa', child: Text('Bữa trưa')),
              DropdownMenuItem(value: 'Bữa tối', child: Text('Bữa tối')),
            ],
            onChanged: (value) {},
          ),
        ),
      ),
    );
  }
}
