import 'package:flutter/material.dart';

class Fridge extends StatefulWidget {
  const Fridge({super.key});

  @override
  State<Fridge> createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Xử lý khi bấm vào nút quay lại
          },
        ),
        title: const Text(
          "Tủ lạnh",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Nguyên liệu, thành phần",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách danh mục nguyên liệu (cuộn ngang)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  _buildCategoryItem(icon: Icons.add, label: "Thẻ mới"),
                  _buildCategoryItem(imagePath: "images/fish.png", label: "Thịt"),
                  _buildCategoryItem(imagePath: "images/fish.png", label: "Rau"),
                  _buildCategoryItem(imagePath: "images/fish.png", label: "Củ quả"),
                  _buildCategoryItem(imagePath: "images/fish.png", label: "Hộp"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gợi ý nguyên liệu cần mua (cuộn ngang)
            const Text(
              "Gợi ý nguyên liệu cần mua",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSuggestionCard("Thịt bò", "0 Kg", "images/fish.png"),
                  _buildSuggestionCard("Thịt gà", "0 Kg", "images/fish.png"),
                  _buildSuggestionCard("Ới", "0 Kg", "images/fish.png"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách nguyên liệu (cuộn dọc)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Danh sách nguyên liệu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Xử lý khi bấm "Chỉnh sửa"
                  },
                  child: const Text(
                    "Chỉnh sửa",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIngredientItem("Nước mắm", "1 L", "images/fish.png"),
                _buildIngredientItem("Gạo trắng", "5 KG", "images/fish.png"),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddIngredientPopup(context);
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildCategoryItem({IconData? icon, String? imagePath, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: icon != null
                ? Icon(icon, color: Colors.grey, size: 30)
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  Widget _buildSuggestionCard(String name, String quantity, String imagePath) {
    return Container(
      width: 140, // Chiều rộng cố định cho mỗi thẻ
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[300]!), // Viền nhẹ
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh với nút "Mua thêm" nổi lên trên
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), // Màu mờ phủ lên hình ảnh
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12.5,
                left: 28,
                child: ElevatedButton(
                  onPressed: () {
                    // Hành động khi bấm "Mua thêm"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text(
                    "Mua thêm",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên món hàng
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Số lượng
                Row(
                  children: [
                    const Icon(Icons.shopping_basket, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      quantity,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    const Spacer(),
                    const Icon(Icons.group, size: 12, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildIngredientItem(String name, String quantity, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(quantity, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );


  }
  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[200],
      labelStyle: const TextStyle(color: Colors.black),
    );
  }
  void _showAddIngredientPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Thêm thực phẩm mới",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tên thực phẩm
            TextField(
              decoration: InputDecoration(
                labelText: "Tên thực phẩm",
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
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

            // Số lượng
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Số lượng",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Kg',
                  items: <String>['Kg', 'L', 'Gram'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    // Xử lý khi thay đổi đơn vị
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


}


