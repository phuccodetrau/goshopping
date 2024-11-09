import 'package:flutter/material.dart';
import 'user/persion_infor_change.dart';
import 'begin/splashScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  // Ensure that the dotenv file is loaded before running the app
  await dotenv.load();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug
      home:SplashScreen()// Sử dụng Begin() làm widget chính của app
    );
  }
}
