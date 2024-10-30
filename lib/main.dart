import 'package:flutter/material.dart';
import 'buy_food.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug
      home:BuyFood() // Sử dụng Begin() làm widget chính của app
    );
  }
}
