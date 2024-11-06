import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Thêm SingleChildScrollView để cuộn nội dung
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Action khi bấm nút quay lại
                },
              ),
              SizedBox(height: 20),
              Text(
                'Chào mừng bạn đến với',
                style: TextStyle(fontSize: 24,  fontWeight: FontWeight.bold,color: Colors.green[800]),
              ),
              Text(
                'Đi Chợ Tiện Lợi!',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('images/flag.png', width: 24, height: 24), // biểu tượng quốc kỳ
                  ),
                  hintText: '+84',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {
                      // Action khi chọn checkbox
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Tôi đồng ý với các ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Chính sách quyền riêng tư của Đi Chợ Tiện Lợi',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Action khi bấm nút "Tiếp tục với Số điện thoại"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text(
                    'Tiếp tục với Số điện thoại',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

