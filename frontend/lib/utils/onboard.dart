import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;


  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Image.asset(imagePath, height: 250), // Adjust height as necessary
          Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          Spacer(),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}