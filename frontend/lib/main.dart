import 'package:flutter/material.dart';
// import 'user/persion_infor_change.dart';
import 'home_screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug
      home: HomeScreen() // Sử dụng Begin() làm widget chính của app
    );
  }
}
