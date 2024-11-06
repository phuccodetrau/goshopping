import 'package:flutter/material.dart';

class BuyFood extends StatefulWidget {
  const BuyFood({super.key});

  @override
  _BuyFoodState createState() => _BuyFoodState();
}

class _BuyFoodState extends State<BuyFood> {
  String selectedUnit = 'Kg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Action quay lại
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biểu ngữ trên cùng
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('images/fish.png'), // Đường dẫn đến ảnh biểu ngữ
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tên thực phẩm",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            // Tên thực phẩm
            TextField(
              decoration: InputDecoration(
                labelText: "Tên thực phẩm",
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Loại thực phẩm
            Text(
              "Loại thực phẩm",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip("Ngũ cốc"),
                _buildChip("Gia vị"),
                _buildChip("Thịt"),
                _buildChip("Trứng, Sữa"),
                _buildChip("Rau"),
                _buildChip("Củ quả"),
                _buildChip("Hoa quả"),
              ],
            ),
            const SizedBox(height: 16),

            // Số lượng và phân công
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Số lượng",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedUnit,
                  items: <String>['Kg', 'L', 'Gram', 'Tạo mới'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue == 'Tạo mới') {
                      _showCreateUnitDialog();
                    } else {
                      setState(() {
                        selectedUnit = newValue!;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Phân công",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: <String>['Hoàng', 'An', 'Bình'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      // Xử lý khi thay đổi phân công
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thời gian thực hiện dự kiến
            Text(
              "Thời gian thực hiện dự kiến",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Tuesday, 15 May, 2024",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "11:30 AM - 6:30PM",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Xử lý khi chuyển đổi tab
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  void _showCreateUnitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tạo đại lượng mới"),
          content: const TextField(
            decoration: InputDecoration(
              hintText: "Tên đại lượng mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                // Thêm đại lượng mới
                Navigator.of(context).pop();
              },
              child: const Text("Tạo mới"),
            ),
          ],
        );
      },
    );
  }
}
