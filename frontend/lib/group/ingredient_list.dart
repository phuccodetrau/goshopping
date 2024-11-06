import 'package:flutter/material.dart';

class IngredientListScreen extends StatelessWidget {
  const IngredientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Xử lý khi nhấn nút quay lại
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              // Xử lý khi nhấn nút về trang chủ
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Nguyên liệu, thành phần',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              'Danh sách nguyên liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),

            // Danh sách nguyên liệu
            Expanded(
              child: ListView(
                children: [
                  IngredientCard(
                    imagePath: 'images/group.png', // Đường dẫn hình ảnh
                    name: 'Nước mắm',
                    quantity: '1 L',
                  ),
                  IngredientCard(
                    imagePath: 'images/group.png', // Đường dẫn hình ảnh
                    name: 'Gạo trắng',
                    quantity: '5 KG',
                  ),
                  IngredientCard(
                    imagePath: 'images/group.png', // Đường dẫn hình ảnh
                    name: 'Gạo trắng',
                    quantity: '5 KG',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Nút thêm mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          // Xử lý khi nhấn nút thêm
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget cho từng nguyên liệu
class IngredientCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String quantity;

  const IngredientCard({super.key, 
    required this.imagePath,
    required this.name,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        subtitle: Text(quantity),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Xử lý khi nhấn nút "more"
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IngredientListScreen(),
  ));
}
