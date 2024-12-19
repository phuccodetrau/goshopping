import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/user_provider.dart';
import 'services/user_service.dart';
import 'repositories/user_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // Cấu hình OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
  OneSignal.Notifications.clearAll();
  await OneSignal.Notifications.requestPermission(true);
  
  // Theo dõi trạng thái subscription
  OneSignal.User.pushSubscription.addObserver((state) {
    print('Push subscription changed:');
    print('Opted in: ${state.current.optedIn}');
    print('Token: ${state.current.id}');
  });
  
  // Xử lý notification
  OneSignal.Notifications.addClickListener((event) {
    print("Clicked notification: ${event.notification.additionalData}");
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Received notification: ${event.notification.additionalData}");
    event.notification.display();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserService>(
          create: (_) => UserService(),
        ),
        ProxyProvider<UserService, UserRepository>(
          create: (_) => UserRepository(
            apiService: _.read<UserService>(),
          ),
          update: (_, apiService, previous) => UserRepository(
            apiService: apiService,
          ),
        ),
        ChangeNotifierProxyProvider<UserRepository, UserProvider>(
          create: (context) => UserProvider(
            repository: context.read<UserRepository>(),
          ),
          update: (_, repository, previous) {
            if (previous == null) throw Exception('Previous UserProvider was null');
            previous.repository = repository;
            return previous;
          },
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('vi', 'VN'),
        ],
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
        },
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
