import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          '',
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
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm trong danh sách món ăn',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề "Bữa sáng" và nút chỉnh sửa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bữa sáng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  // Thông tin thời gian và ngày
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.green),
                            SizedBox(width: 8),
                            Text('7:30 - 8:30 AM'),
                            Spacer(),
                            Icon(Icons.calendar_today, color: Colors.green),
                            SizedBox(width: 8),
                            Text('20 Tháng 10, 2024'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.green),
                            SizedBox(width: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text('Hùng'),
                                  backgroundColor: Colors.green[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Điều chỉnh góc bo tròn ở đây
                                    side: BorderSide(color: Colors.green[700]!), // Đặt màu viền nếu muốn
                                  ),
                                ),
                                Chip(
                                  label: Text('Hương'),
                                  backgroundColor: Colors.green[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Điều chỉnh góc bo tròn ở đây
                                    side: BorderSide(color: Colors.green[700]!), // Đặt màu viền nếu muốn
                                  ),
                                ),
                                Chip(
                                  label: Text('Hoàng'),
                                  backgroundColor: Colors.green[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Điều chỉnh góc bo tròn ở đây
                                    side: BorderSide(color: Colors.green[700]!), // Đặt màu viền nếu muốn
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Danh sách món ăn đã chọn
                  Text(
                    'Danh sách món ăn đã chọn',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Danh sách các món ăn
                  MealItemCard(
                    imagePath: 'images/group.png',
                    title: 'Canh rau ngót',
                    description: 'Rau ngót, thịt băm, hành, hạt nêm...',
                  ),
                  MealItemCard(
                    imagePath: 'images/group.png',
                    title: 'Đậu hũ sốt cà',
                    description: 'Đậu hũ, thịt băm, hành, hạt nêm...',
                  ),
                  MealItemCard(
                    imagePath: 'images/group.png',
                    title: 'Bún thịt nướng',
                    description: 'Bún, thịt băm, hành, hạt nêm...',
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
