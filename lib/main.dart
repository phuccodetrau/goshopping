import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'begin/splashScreen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // Cấu hình OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  
  // Yêu cầu quyền thông báo và khởi tạo
  await OneSignal.Notifications.requestPermission(true);
  
  // Xử lý khi nhận được thông báo
  OneSignal.Notifications.addClickListener((event) {
    print("Clicked notification: ${event.notification.additionalData}");
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Received notification: ${event.notification.additionalData}");
    event.notification.display(); // Hiển thị thông báo ngay cả khi app đang mở
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}
