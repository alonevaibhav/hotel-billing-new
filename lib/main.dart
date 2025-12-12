
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import 'app/core/services/api_service.dart';
import 'app/core/services/notification_service.dart';
import 'app/core/services/notification_storage_service.dart';
import 'app/core/services/session_manager_service.dart';
import 'app/core/services/storage_service.dart';
import 'app/modules/service/socket_connection_manager.dart';
import 'app/route/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await ApiService.init();
  await GetStorage.init();
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => NotificationService().init());
  Get.put(NotificationStorageController());


  // ✅ Initialize Socket Connection Manager
  await SocketConnectionManager.init();


  // Check authentication status
  final authData = await TokenManager.checkAuthenticationWithRole();
  developer.log(
    'Startup auth check - Authenticated: ${authData['isAuthenticated']}, Role: ${authData['userRole']}, User: ${authData['userName']}',
    name: 'Main',
  );

  // ✅ Connect socket if user is already authenticated
  if (authData['isAuthenticated'] == true) {
    await SocketConnectionManager.instance.connectFromAuthData(authData);
  } else {
    developer.log(
      'User not authenticated, skipping socket connection',
      name: 'Main.Socket',
    );
  }

  // Initialize bindings
  AppRoutes.initializeBindings();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp(authData: authData));
}

class MyApp extends StatefulWidget {
  final Map<String, dynamic> authData;

  const MyApp({super.key, required this.authData});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initializeRouter();
  }

  void _initializeRouter() {
    final currentLocation = NavigationService.currentLocation;

    developer.log(
      'Initializing router - Current location: $currentLocation',
      name: 'MyApp',
    );

    _router = AppRoutes.getRouter(
      authData: widget.authData,
      currentLocation: currentLocation,
    );

    NavigationService.initialize(_router);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: _router,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          ),
          debugShowCheckedModeBanner: false,
          title: 'Hotel-Billing',
        );
      },
    );
  }
}