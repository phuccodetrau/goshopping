import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'screens/auth/splash_screen.dart';
import 'providers/user_provider.dart';
import 'providers/group_provider.dart';
import 'repositories/user_repository.dart';
import 'repositories/group_repository.dart';
import 'services/user_service.dart';
import 'services/group_service.dart';
import 'services/notification_service.dart';
import 'repositories/notification_repository.dart';
import 'services/food_service.dart';
import 'repositories/food_repository.dart';
import 'services/list_task_service.dart';
import 'repositories/list_task_repository.dart';
import 'services/statistics_service.dart';
import 'repositories/statistics_repository.dart';
import 'services/meal_plan_service.dart';
import 'repositories/meal_plan_repository.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // OneSignal Configuration
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
  OneSignal.Notifications.clearAll();
  await OneSignal.Notifications.requestPermission(true);
  
  // Push subscription observer
  OneSignal.User.pushSubscription.addObserver((state) {
    print('Push subscription changed:');
    print('Opted in: ${state.current.optedIn}');
    print('Token: ${state.current.id}');
    print('Status: ${state.current.jsonRepresentation()}');
  });
  
  // Notification handlers
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
        // Services
        Provider<UserService>(create: (_) => UserService()),
        Provider<GroupService>(create: (_) => GroupService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<FoodService>(create: (_) => FoodService()),
        Provider<ListTaskService>(create: (_) => ListTaskService()),
        Provider<StatisticsService>(create: (_) => StatisticsService()),
        Provider<MealPlanService>(create: (_) => MealPlanService()),

        // Repositories
        ProxyProvider<UserService, UserRepository>(
          update: (_, userService, __) => UserRepository(apiService: userService),
        ),
        ProxyProvider<GroupService, GroupRepository>(
          update: (_, groupService, __) => GroupRepository(groupService: groupService),
        ),
        ProxyProvider<NotificationService, NotificationRepository>(
          update: (_, notificationService, __) => NotificationRepository(notificationService: notificationService),
        ),
        ProxyProvider<FoodService, FoodRepository>(
          update: (_, foodService, __) => FoodRepository(foodService: foodService),
        ),
        ProxyProvider<ListTaskService, ListTaskRepository>(
          update: (_, taskService, __) => ListTaskRepository(taskService: taskService),
        ),
        ProxyProvider<StatisticsService, StatisticsRepository>(
          update: (_, statisticsService, __) => StatisticsRepository(statisticsService: statisticsService),
        ),
        ProxyProvider<MealPlanService, MealPlanRepository>(
          update: (_, mealPlanService, __) => MealPlanRepository(apiService: mealPlanService),
        ),

        // Providers
        ChangeNotifierProxyProvider<UserRepository, UserProvider>(
          create: (context) => UserProvider(repository: Provider.of<UserRepository>(context, listen: false)),
          update: (_, repository, previous) => previous ?? UserProvider(repository: repository),
        ),
        ChangeNotifierProxyProvider<GroupRepository, GroupProvider>(
          create: (context) => GroupProvider(repository: Provider.of<GroupRepository>(context, listen: false)),
          update: (_, repository, previous) => previous ?? GroupProvider(repository: repository),
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'Đi Chợ Tiện Lợi',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
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
        home: const SplashScreen(),
      ),
    );
  }
}
