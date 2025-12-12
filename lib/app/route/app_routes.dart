
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../core/services/notification_storage_service.dart';
import '../data/models/ResponseModel/table_model.dart';
import '../modules/auth/login_view.dart';
import '../modules/view/ChefPanel/dashboard.dart';
import '../modules/view/ChefPanel/sidebar/chef_history/chef_history.dart';
import '../modules/view/WaiterPanel/home_page.dart';
import '../modules/view/WaiterPanel/TakeOrder/AddItems/add_items_view.dart';
import '../modules/view/WaiterPanel/TakeOrder/OrderView/order_view_main.dart';
import '../modules/view/WaiterPanel/sidebar/waiter_history/order_history_view.dart';
import '../modules/view/WaiterPanel/sidebar/waiter_notification.dart';
import 'app_bindings.dart';

class AppRoutes {
  // Route names
  static const login = '/login';
  static const forgotPassword = '/forgotPassword';

  // Waiter Routes
  static const waiterDashboard = '/restaurant';
  static const selectItem = '/restaurant/selectItem';
  static const addItems = '/restaurant/selectItem/addItems';
  static const waiterHistoryView = '/restaurant/orderView';
  static const waiterNotificationView = '/restaurant/NotificationView';

  // Chef Routes
  static const chefDashboard = '/chefDashboard';
  static const chefHistoryView = '/chefDashboard/orderView';


  // Initialize bindings once at app start
  static void initializeBindings() {
    AppBindings().dependencies();
  }

  // Create router based on authentication data
  static GoRouter getRouter({
    required Map<String, dynamic> authData,
    String? currentLocation, // Add this parameter
  }) {
    final isAuthenticated = authData['isAuthenticated'] ?? false;
    final userRole = authData['userRole'] as String?;
    final userName = authData['userName'] as String?;

    // Use currentLocation if provided (hot reload case), otherwise determine from auth
    String initialLocation = currentLocation ?? login;

    if (currentLocation == null && isAuthenticated && userRole != null) {
      initialLocation = _getInitialLocationByRole(userRole);
    }

    developer.log('Router setup - Initial: $initialLocation, Auth: $isAuthenticated, Role: $userRole, User: $userName', name: 'AppRoutes');

    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        // Auth Routes
        GoRoute(
          path: login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const Placeholder(),
        ),

        // Waiter Routes
        GoRoute(
          path: waiterDashboard,
          builder: (context, state) => const WaiterDashboardView(),
        ),
        GoRoute(
          path: selectItem,
          builder: (context, state) {
            final tableInfo = state.extra as TableInfo?;
            return OrderManagementView(tableInfo: tableInfo);
          },
        ),
        GoRoute(
          path: addItems,
          builder: (context, state) {
            final table = state.extra as Map<String, dynamic>?;
            return AddItemsView(table: table);
          },
        ),
        GoRoute(
          path: waiterHistoryView,
          builder: (context, state) => const WaiterOrderHistoryView(),
        ),
        GoRoute(
          path: waiterNotificationView,
          builder: (context, state) {
            final controller = Get.find<NotificationStorageController>();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.refreshNotifications();
            });

            return WaiterNotificationPage();
          },
        ),


        // Chef Routes
        GoRoute(
          path: chefDashboard,
          builder: (context, state) => const ChefDashboard(),
        ),
        GoRoute(
          path: chefHistoryView,
          builder: (context, state) => const ChefOrderHistoryView(),
        ),
      ],
    );
  }

  // Helper method to get initial location by role
  static String _getInitialLocationByRole(String role) {
    switch (role.toLowerCase()) {
      case 'waiter':
        return waiterDashboard;
      case 'chef':
        return chefDashboard;
      default:
        developer.log('Unknown role: $role, defaulting to login', name: 'AppRoutes');
        return login;
    }
  }
}

// Clean Navigation Service
class NavigationService {
  static GoRouter? _router;

  // Initialize the router
  static void initialize(GoRouter router) {
    _router = router;
    developer.log('NavigationService initialized', name: 'NavigationService');
  }

  // Get the router instance
  static GoRouter get router {
    if (_router == null) {
      throw Exception('NavigationService not initialized. Call NavigationService.initialize() first.');
    }
    return _router!;
  }

  // Get current location
  static String? get currentLocation {
    return _router?.routerDelegate.currentConfiguration.uri.toString();
  }

  // Navigation methods
  static void goToLogin() {
    router.go(AppRoutes.login);
  }

  static void goToWaiterDashboard() {
    router.go(AppRoutes.waiterDashboard);
  }

  static void goToChefDashboard() {
    router.go(AppRoutes.chefDashboard);
  }

  static void selectItem(TableInfo tableInfo) {
    router.push(AppRoutes.selectItem, extra: tableInfo);
  }

  static void addItems(Map<String, dynamic>? table) {
    router.push(AppRoutes.addItems, extra: table);
  }

  static void pushToWaiterHistory() {
    router.push(AppRoutes.waiterHistoryView);
  }
  static void pushToWaiterNotification() {
    router.push(AppRoutes.waiterNotificationView);
  }


  static void pushToChefHistory() {
    router.push(AppRoutes.chefHistoryView);
  }

  static void goBack() {
    if (router.canPop()) {
      developer.log('Navigating back', name: 'NavigationService');
      router.pop();
    } else {
      developer.log('Cannot navigate back - no routes in stack', name: 'NavigationService');
    }
  }

  static bool canGoBack() => router.canPop();
}