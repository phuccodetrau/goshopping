import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

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
      body: Column(
        children: [
          // Phần thông tin người dùng
          Container(
            color: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/group.png'), // Thay bằng đường dẫn ảnh của bạn
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
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.video_call, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.call, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Thống kê
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticCard('03', 'Nhóm đã tham gia', Colors.orange[300]!),
                _buildStatisticCard('50+', 'Món mới', Colors.green[300]!),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Các tùy chọn
          Expanded(
            child: ListView(
              children: [
                _buildListTile(Icons.person, 'Chỉnh sửa thông tin cá nhân'),
                _buildListTile(Icons.upgrade, 'Nâng cấp phiên bản'),
                _buildListTile(Icons.star, 'Đánh giá'),
                _buildListTile(Icons.share, 'Chia sẻ với bạn bè'),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    // Xử lý khi nhấn Đăng xuất
                  },
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildStatisticCard(String number, String label, Color color) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Xử lý khi nhấn vào mục
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PersonalInfoScreen(),
  ));
}
