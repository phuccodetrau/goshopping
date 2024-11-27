import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'begin/splashScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
Future<void> main() async {
  // Ensure that the dotenv file is loaded before running the app
  await dotenv.load();
  runApp(const MyApp());

  // Noti
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("a4c8fa0a-a521-4c77-8ac2-76a788f8d146");
  OneSignal.Notifications.requestPermission(true);

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false, // Tắt banner debug
      home:SplashScreen()// Sử dụng Begin() làm widget chính của app
    );
  }
}
