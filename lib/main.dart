import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'begin/splashScreen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // Cấu hình chi tiết cho OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
  
  // Xóa các thông báo cũ
  OneSignal.Notifications.clearAll();
  
  // Cấu hình thêm
  await OneSignal.Notifications.requestPermission(true);
  
  // Theo dõi trạng thái subscription
  OneSignal.User.pushSubscription.addObserver((state) {
    print('Push subscription changed:');
    print('Opted in: ${state.current.optedIn}');
    print('Token: ${state.current.id}');
    print('Status: ${state.current.jsonRepresentation()}');
  });
  
  // Xử lý notification
  OneSignal.Notifications.addClickListener((event) {
    print("Clicked notification: ${event.notification.additionalData}");
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Received notification: ${event.notification.additionalData}");
    event.notification.display();
  });

  runApp(MyApp());
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
