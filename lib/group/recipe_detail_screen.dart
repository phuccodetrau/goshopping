import 'package:flutter/material.dart';

class RecipeDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Phần chứa hình ảnh và thông tin món ăn
            Stack(
              children: [
                // Màu nền phía trên
                Container(
                  height: 120,
                  color: Colors.green[700],
                ),
                // Phần chứa hình ảnh và thông tin món ăn
                Column(
                  children: [
                    SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('images/group.png'), // Thay bằng đường dẫn hình ảnh của bạn
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pad Thái',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    Row(
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
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
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
                  IngredientCard(
                    imagePath: 'images/group.png', // Thay bằng đường dẫn hình ảnh của bạn
                    name: 'Tôm sú',
                    quantity: '0.5 Kg',
                    remaining: 'Còn lại: 0.1 Kg',
                    buttonLabel: 'Mua thêm',
                    buttonColor: Colors.green,
                  ),
                  IngredientCard(
                    imagePath: 'images/group.png', // Thay bằng đường dẫn hình ảnh của bạn
                    name: 'Đậu phộng',
                    quantity: '0.1 Kg',
                    remaining: 'Còn lại: 1 Kg',
                    buttonLabel: 'Mua thêm',
                    buttonColor: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Colors.green[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
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
                    'Ngâm sợi Pad Thái trong nước lạnh 15 phút để nở. '
                        'Tôm sú bóc vỏ, rửa sạch, để ráo. Đậu phộng thái nhuyễn khô dầu. '
                        'Tỏi băm nhuyễn. Hành lá rửa sạch, cắt nhó. '
                        'Hòa các loại gia vị vào một chén, khuấy đều. '
                        'Đổ nước xào tôm vào cùng với mì cho đến khi chín...',
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

// Widget cho mỗi nguyên liệu
class IngredientCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String quantity;
  final String remaining;
  final String buttonLabel;
  final Color buttonColor;

  IngredientCard({
    required this.imagePath,
    required this.name,
    required this.quantity,
    required this.remaining,
    required this.buttonLabel,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
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
            SizedBox(width: 16),
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
                  Text(quantity),
                  Text(
                    remaining,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RecipeDetail(),
  ));
}
