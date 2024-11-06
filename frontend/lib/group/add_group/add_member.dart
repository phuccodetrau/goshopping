import 'package:flutter/material.dart';

class AddMember extends StatelessWidget {
  const AddMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "",
          style: TextStyle(color: Colors.green),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Tạo nhóm",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Nhập Tên hoặc Email để tìm kiếm",
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // User profile
            Row(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("images/group.png"),
                      radius: 30,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Thêm logic để xóa hoặc thực hiện hành động cần thiết
                        },
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

              ],
            ),
            const SizedBox(height: 20),
            // Suggested contacts title
            const Text(
              "Gợi ý",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            // Suggested contacts list
            Expanded(
              child: ListView(
                children: const [
                  ContactItem(
                      name: "Hoanghung_1000",
                      image: "images/group.png",
                      isSelected: true),
                  ContactItem(
                      name: "Thaomy_1000",
                      image: "images/group.png",
                      isSelected: false),
                  ContactItem(
                      name: "Alice_200",
                      image: "images/group.png",
                      isSelected: false),
                  ContactItem(
                      name: "Tom_1000",
                      image: "images/group.png",
                      isSelected: false),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;

  const ContactItem({super.key, 
    required this.name,
    required this.image,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 20,
      ),
      title: Text(name),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.green : Colors.grey,
      ),
    );
  }
}
