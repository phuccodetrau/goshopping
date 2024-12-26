import 'package:flutter/material.dart';
import 'begin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false; // Đảm bảo không điều hướng nhiều lần

  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nếu người dùng quay lại trang này (bằng nút back), khởi động lại điều hướng
    if (!_isNavigating) {
      _startNavigation();
    }
  }

  void _startNavigation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isNavigating) {
        _isNavigating = true; // Đảm bảo chỉ điều hướng 1 lần
        Navigator.pushReplacement(
          context,
          _createRoute(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("images/logo.png"),
                  width: 100,
                ),
                SizedBox(height: 10),
                Text(
                  'ĐI CHỢ TIỆN LỢI',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo hiệu ứng chuyển màn hình
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const OnBoardingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
