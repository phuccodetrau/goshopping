import 'package:flutter/material.dart';

class FoodListScreen extends StatelessWidget {
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
            onPressed: () {},
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
                  FoodSuggestionImage('images/group.png'),
                  FoodSuggestionImage('images/group.png'),
                  FoodSuggestionImage('images/group.png'),
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
                  FoodItemCard(
                    imagePath: 'images/group.png',
                    title: 'Canh rau ngót',
                    description: 'Rau ngót, thịt băm, hành, hạt nêm...',
                  ),
                  FoodItemCard(
                    imagePath: 'images/group.png',
                    title: 'Đậu hũ sốt cà',
                    description: 'Đậu hũ, thịt băm, hành, hạt nêm...',
                  ),
                  FoodItemCard(
                    imagePath: 'images/group.png',
                    title: 'Bún thịt nướng',
                    description: 'Bún, thịt băm, hành, hạt nêm...',
                  ),
                  FoodItemCard(
                    imagePath: 'images/group.png',
                    title: 'Nem rán',
                    description: 'Thịt băm, hành, nấm, cà rốt...',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}

// Widget cho phần gợi ý hình ảnh món ăn
class FoodSuggestionImage extends StatelessWidget {
  final String imagePath;

  FoodSuggestionImage(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Widget cho từng món ăn trong danh sách
class FoodItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  FoodItemCard({
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
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: DropdownButton<String>(
          underline: SizedBox(),
          icon: Icon(Icons.more_vert, color: Colors.green[700]),

          items: [
            DropdownMenuItem(value: 'Bữa sáng', child: Text('Bữa sáng')),
            DropdownMenuItem(value: 'Bữa trưa', child: Text('Bữa trưa')),
            DropdownMenuItem(value: 'Bữa tối', child: Text('Bữa tối')),
          ],
          onChanged: (value) {

          },
        ),
      ),
    );
  }
}
