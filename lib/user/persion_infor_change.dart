import 'package:flutter/material.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Xử lý khi nhấn nút quay lại
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Phần thông tin người dùng
            Container(
              color: Colors.green[700],
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(

                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('images/group.png'), // Đường dẫn tới ảnh đại diện của bạn
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hung Hoang Dinh',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '@hoanghung',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Chỉnh sửa thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Trường Tên của bạn
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Tên của bạn",
                      hintText: "Hoàng Đình Hùng",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Trường Email
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "hoanghung1111@gmail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  // Trường Nhập số điện thoại
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Nhập số điện thoại",
                      hintText: "+84 256 235 235",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.asset(
                          'images/flag.png', // Đường dẫn tới ảnh lá cờ
                          width: 24,
                          height: 24,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 24),
                  // Nút Lưu thông tin
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý khi nhấn nút Lưu thông tin
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Lưu thông tin',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Xử lý khi chuyển đổi tab
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
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
}

