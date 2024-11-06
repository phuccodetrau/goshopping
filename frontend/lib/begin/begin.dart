import 'package:flutter/material.dart';
import '../utils/onboard.dart';
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _onNext() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      // Đưa ra hành động khi đã đến trang cuối (vd: vào màn hình chính)
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
              child: const Text(
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _onNext,
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? "Tiếp tục"
                      : "Tiếp theo",
                  style: const TextStyle(color: Colors.white),
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
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
