import 'dart:convert';

import 'package:flutter/material.dart';
import '../home_screen/home_screen.dart';
import '../utils/onboard.dart';
import 'login_register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  String URL = dotenv.env['ROOT_URL']!+ "/auth/user/check_login";
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initialize(); // Call the async method here
  }

  Future<void> _initialize() async {
    final String email = await getEmail();
    print(email);

    if (email.isNotEmpty) { // Check if email is not empty
      if (await check_email(email)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    }
  }

  Future<String> getEmail() async {
    final email = await _secureStorage.read(key: "email");
    print(await _secureStorage.read(key: "auth_token"));
    return email ?? ''; // Return empty string if email is null
  }

  Future<bool> check_email(String email) async {
    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);

      return responseData['status'] == true;
    } catch (e) {
      print(e); // Optional: print the error
      return false;
    }
  }
  PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "imagePath": 'images/market_1.png',
      "title": 'Quản lí bữa ăn',
      "subtitle": 'Phân công công việc chuẩn bị rõ ràng',
    },
    {
      "imagePath": 'images/market_2.png',
      "title": 'Đi chợ tiện lợi',
      "subtitle": 'Lên danh sách, kiểm soát định lượng thức ăn',
    },
    {
      "imagePath": 'images/market_3.png',
      "title": 'Đi chợ tiện lợi',
      "subtitle": 'Lên danh sách, kiểm soát định lượng thức ăn',
    }
  ];

  void _onSkip() {
    // Chuyển đến trang cuối cùng
    _pageController.animateToPage(
      onboardingData.length - 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LoginRegisterScreen();
    }));
  }

  void _onNext() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoginRegisterScreen();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                imagePath: onboardingData[index]["imagePath"]!,
                title: onboardingData[index]["title"]!,
                subtitle: onboardingData[index]["subtitle"]!,
              );
            },
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _onSkip,
              child: Text(
                "Bỏ qua",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _onNext,
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? "Tiếp tục"
                      : "Tiếp theo",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
