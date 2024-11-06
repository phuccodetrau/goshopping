import 'package:flutter/material.dart';
class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background_login.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Login Button and Text
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  // Action khi bấm nút đăng nhập
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: OutlinedButton(
                onPressed: () {
                  // Action khi bấm "Bạn chưa có tài khoản?"
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white), // Viền trắng
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text(
                    'Bạn chưa có tài khoản?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ],
    );
  }
}
