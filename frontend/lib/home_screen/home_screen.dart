import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cộng đồng',
          style: TextStyle(
            fontSize: 24,
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[700]),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tìm kiếm nhóm
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm nhóm',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Thẻ nhóm
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Hình ảnh nhóm
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('images/group.png'), // Thay bằng đường dẫn hình ảnh của bạn
                    ),
                    SizedBox(width: 12),

                    // Thông tin nhóm
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhóm của bạn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('4 Files'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Admin: @hung123'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Ảnh đại diện và số thành viên
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('images/group.png'), // Thay bằng đường dẫn hình ảnh của bạn
                        ),
                        SizedBox(height: 4),
                        Text('+1'),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Nút thêm nhóm
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add, color: Colors.white),
      ),

      // Thanh điều hướng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
