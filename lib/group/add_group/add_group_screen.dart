import 'package:flutter/material.dart';

class AddGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Bỏ qua",
              style: TextStyle(color: Colors.green[800]),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "Tùy chỉnh nhóm của bạn",
              style: TextStyle(
                fontSize: 22,
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Cá nhân hóa nhóm của bạn bằng cách đặt tên và thêm hình ảnh đại diện.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 32),

            // Cập nhật hình ảnh
            GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Cập nhật hình ảnh",
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Ô nhập tên nhóm
            TextField(

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: "Đặt tên cho nhóm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                counterText: "0/75",

              ),
              maxLength: 75,
            ),

            SizedBox(height: 16),

            // Thông tin điều khoản
            Text(
              "Khi tạo nhóm, nghĩa là bạn đã đồng ý với ",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Nguyên tắc cộng đồng",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " của Đi chợ tiện lợi.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Nút "Tiếp theo"
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: Text(
                "Tiếp theo",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
