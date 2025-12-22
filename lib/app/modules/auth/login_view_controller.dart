// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:developer' as developer;
// import '../../core/services/session_manager_service.dart';
// import '../../core/services/storage_service.dart';
// import '../../core/utils/snakbar_utils.dart';
// import '../../data/models/ResponseModel/login_response_model.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../route/app_routes.dart';
// import '../service/socket_connection_manager.dart';
//
// class LoginViewController extends GetxController {
//   // Form key for validation
//   final formKey = GlobalKey<FormState>();
//
//   // Text editing controllers
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   // Observable variables
//   final isLoading = false.obs;
//   final isPasswordVisible = false.obs;
//   final rememberMe = false.obs;
//   final errorMessage = ''.obs;
//
//   // Store login response data
//   final loginResponse = Rxn<LoginResponseModel>();
//   final currentEmployee = Rxn<Employee>();
//
//   // ✅ Use Socket Connection Manager
//   final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('Login controller initialized', name: 'LoginController');
//     _startTokenMonitoring();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     developer.log('Login controller ready', name: 'LoginController');
//     _checkExistingAuthentication();
//   }
//
//   @override
//   void onClose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     TokenManager.stopTokenExpirationTimer();
//     developer.log('Login controller disposed', name: 'LoginController');
//     super.onClose();
//   }
//
//   /// Check if user is already authenticated on app start
//   void _checkExistingAuthentication() async {
//     final authData = await TokenManager.checkAuthenticationWithRole();
//
//     if (authData['isAuthenticated']) {
//       developer.log(
//         'User already authenticated, navigating based on role: ${authData['userRole']}',
//         name: 'LoginController',
//       );
//
//       // ✅ Socket Connection Manager handles duplicate prevention automatically
//       await _socketManager.connectFromAuthData(authData);
//
//       _navigateByRole(authData['userRole'], authData['userName']);
//     } else {
//       developer.log(
//         'No valid authentication found, staying on login screen',
//         name: 'LoginController',
//       );
//     }
//   }
//
//
//   /// Start token expiration monitoring
//   void _startTokenMonitoring() {
//     TokenManager.startTokenExpirationTimer(
//       interval: Duration(minutes: 5),
//       onTokenExpired: () {
//         _handleTokenExpiration();
//       },
//     );
//   }
//
//   void clearAuthData() {
//     loginResponse.value = null;
//     currentEmployee.value = null;
//     usernameController.clear();
//     passwordController.clear();
//     rememberMe.value = false;
//     errorMessage.value = '';
//   }
//
//   /// Handle token expiration during app usage
//   void _handleTokenExpiration() async {
//     developer.log('Token expired, logging out user', name: 'LoginController');
//
//     if (Get.context != null) {
//       SnackBarUtil.showError(
//         Get.context!,
//         'Your session has expired. Please login again.',
//         title: 'Session Expired',
//         duration: const Duration(seconds: 4),
//       );
//     }
//
//     await logout(sessionExpired: true);
//   }
//
//   /// Navigate user based on their role
//   void _navigateByRole(String? role, String? userName) {
//     if (role == null) {
//       developer.log(
//         'No role found, staying on login',
//         name: 'LoginController.Navigation',
//       );
//       NavigationService.goToLogin();
//       return;
//     }
//
//     switch (role.toLowerCase()) {
//       case 'waiter':
//         developer.log(
//           'Navigating to Waiter Dashboard for: $userName',
//           name: 'LoginController.Navigation',
//         );
//         NavigationService.goToWaiterDashboard();
//         break;
//       case 'chef':
//         developer.log(
//           'Navigating to Chef Dashboard for: $userName',
//           name: 'LoginController.Navigation',
//         );
//         NavigationService.goToChefDashboard();
//         break;
//       default:
//         developer.log(
//           'Unknown role: $role for $userName, staying on login',
//           name: 'LoginController.Navigation',
//         );
//         NavigationService.goToLogin();
//         break;
//     }
//   }
//
//   // UI Methods
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//     developer.log(
//       'Password visibility toggled: ${isPasswordVisible.value}',
//       name: 'LoginController.UI',
//     );
//   }
//
//   void toggleRememberMe(bool? value) {
//     rememberMe.value = value ?? false;
//     developer.log(
//       'Remember me toggled: ${rememberMe.value}',
//       name: 'LoginController.UI',
//     );
//   }
//
//   // Validation Methods
//   String? validateUsername(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Username is required';
//     }
//     if (value.trim().length < 3) {
//       return 'Username must be at least 3 characters';
//     }
//     return null;
//   }
//
//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }
//   /// Submit login with Socket Connection Manager
// // In login_view_controller.dart
//
//   /// Submit login with Socket Connection Manager
//   Future<void> submitLogin(context) async {
//     try {
//       if (!formKey.currentState!.validate()) {
//         developer.log(
//           'Form validation failed',
//           name: 'LoginController.Validation',
//         );
//         return;
//       }
//
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final username = usernameController.text.trim();
//       final password = passwordController.text;
//
//       developer.log(
//         'Starting login for username: $username',
//         name: 'LoginController',
//       );
//
//       // AuthRepository handles all data storage
//       final apiResponse = await AuthRepository.login(
//         username: username,
//         password: password,
//       );
//
//       if (apiResponse.success && apiResponse.data != null) {
//         loginResponse.value = apiResponse.data!;
//         currentEmployee.value = apiResponse.data!.data.employee;
//
//         final employee = apiResponse.data!.data.employee;
//         final userRole = employee.designation;
//         final userName = employee.employeeName;
//         final organizationName = employee.organizationName;
//
//         developer.log(
//           'Authentication successful for $userName (Role: $userRole) at $organizationName',
//           name: 'LoginController.Auth',
//         );
//
//         // ✅ ADDED BACK: Connect socket after successful login
//         try {
//           developer.log('🔌 Connecting socket after login...', name: 'LoginController.Socket');
//
//           final authData = await TokenManager.checkAuthenticationWithRole();
//           final connected = await _socketManager.connectFromAuthData(authData);
//
//           if (connected) {
//             developer.log('✅ Socket connected successfully', name: 'LoginController.Socket');
//           } else {
//             developer.log('⚠️ Socket connection failed', name: 'LoginController.Socket');
//           }
//         } catch (socketError) {
//           developer.log(
//             '❌ Socket connection error: $socketError',
//             name: 'LoginController.Socket',
//           );
//           // Don't block login if socket fails
//         }
//
//         // Success handling
//         SnackBarUtil.showSuccess(
//           context,
//           'Welcome back, $userName!\nLogged in to $organizationName',
//           title: 'Login Successful!',
//           duration: const Duration(seconds: 3),
//         );
//
//         // Navigate based on role
//         _navigateByRole(userRole, userName);
//       } else {
//         final errorMsg = apiResponse.errorMessage ?? 'Login failed';
//         developer.log(
//           'Authentication failed: $errorMsg',
//           name: 'LoginController.Auth',
//         );
//
//         errorMessage.value = errorMsg;
//         SnackBarUtil.showError(
//           context,
//           errorMsg,
//           title: 'Login Failed',
//           duration: const Duration(seconds: 4),
//         );
//       }
//     } catch (e) {
//       developer.log(
//         'Login submission error: ${e.toString()}',
//         name: 'LoginController.Error',
//       );
//
//       errorMessage.value = e.toString();
//       SnackBarUtil.showError(
//         context,
//         'An unexpected error occurred. Please try again.',
//         title: 'Error',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//
//   // Navigation Methods
//   void navigateToForgotPassword(BuildContext context) {
//     developer.log(
//       'Navigating to forgot password',
//       name: 'LoginController.Navigation',
//     );
//     context.go('/forgot-password');
//   }
//
//   // Logout method with socket disconnection
//   Future<void> logout({bool sessionExpired = false}) async {
//     try {
//       developer.log(
//         'Logging out user (sessionExpired: $sessionExpired)',
//         name: 'LoginController.Auth',
//       );
//
//       // ✅ Disconnect using Socket Connection Manager
//       _socketManager.disconnect();
//
//       // Clear repository data
//       await AuthRepository.logout();
//
//       // Clear controller data
//       clearAuthData();
//
//       developer.log(
//         'User logged out successfully',
//         name: 'LoginController.Auth',
//       );
//
//       // Navigate to login
//       NavigationService.goToLogin();
//     } catch (e) {
//       developer.log(
//         'Logout error: ${e.toString()}',
//         name: 'LoginController.Error',
//       );
//     }
//   }
//
//   /// Get socket connection status
//   bool get socketConnected => _socketManager.connectionStatus;
//
//   /// Reconnect socket manually (if needed)
//   Future<void> reconnectSocket() async {
//     final authData = await TokenManager.checkAuthenticationWithRole();
//     if (authData['isAuthenticated']) {
//       await _socketManager.connectFromAuthData(authData);
//     }
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../core/services/session_manager_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/snakbar_utils.dart';
import '../../data/models/ResponseModel/login_response_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../route/app_routes.dart';
import '../service/socket_connection_manager.dart';

class LoginViewController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final errorMessage = ''.obs;

  // Store login response data
  final loginResponse = Rxn<LoginResponseModel>();
  final currentEmployee = Rxn<Employee>();

  // ✅ Use Socket Connection Manager
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;

  // 🔥 FIX: Track if we're in a logout process
  static bool _isLoggingOut = false;

  @override
  void onInit() {
    super.onInit();
    developer.log('Login controller initialized', name: 'LoginController');
    _startTokenMonitoring();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('Login controller ready', name: 'LoginController');

    // 🔥 FIX: Don't check auth if we just logged out
    if (!_isLoggingOut) {
      _checkExistingAuthentication();
    } else {
      developer.log(
        'Skipping auth check - logout in progress',
        name: 'LoginController',
      );
      _isLoggingOut = false; // Reset the flag
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    TokenManager.stopTokenExpirationTimer();
    developer.log('Login controller disposed', name: 'LoginController');
    super.onClose();
  }

  /// Check if user is already authenticated on app start
  void _checkExistingAuthentication() async {
    try {
      // 🔥 FIX: Add a small delay to ensure storage is ready
      await Future.delayed(Duration(milliseconds: 50));

      final authData = await TokenManager.checkAuthenticationWithRole();

      if (authData['isAuthenticated']) {
        // 🔥 FIX: Double-check by verifying token still exists
        final token = await TokenManager.getToken();

        if (token == null || token.isEmpty) {
          developer.log(
            'Auth data found but token is missing - clearing stale data',
            name: 'LoginController',
          );
          await AuthRepository.logout();
          return;
        }

        developer.log(
          'User already authenticated, navigating based on role: ${authData['userRole']}',
          name: 'LoginController',
        );

        // ✅ Socket Connection Manager handles duplicate prevention automatically
        await _socketManager.connectFromAuthData(authData);

        _navigateByRole(authData['userRole'], authData['userName']);
      } else {
        developer.log(
          'No valid authentication found, staying on login screen',
          name: 'LoginController',
        );
      }
    } catch (e) {
      developer.log(
        'Error checking authentication: $e',
        name: 'LoginController.Error',
      );
    }
  }

  /// Start token expiration monitoring
  void _startTokenMonitoring() {
    TokenManager.startTokenExpirationTimer(
      interval: Duration(minutes: 5),
      onTokenExpired: () {
        _handleTokenExpiration();
      },
    );
  }

  void clearAuthData() {
    loginResponse.value = null;
    currentEmployee.value = null;
    usernameController.clear();
    passwordController.clear();
    rememberMe.value = false;
    errorMessage.value = '';
  }

  /// Handle token expiration during app usage
  void _handleTokenExpiration() async {
    developer.log('Token expired, logging out user', name: 'LoginController');

    if (Get.context != null) {
      SnackBarUtil.showError(
        Get.context!,
        'Your session has expired. Please login again.',
        title: 'Session Expired',
        duration: const Duration(seconds: 4),
      );
    }

    await logout(sessionExpired: true);
  }

  /// Navigate user based on their role
  void _navigateByRole(String? role, String? userName) {
    if (role == null) {
      developer.log(
        'No role found, staying on login',
        name: 'LoginController.Navigation',
      );
      NavigationService.goToLogin();
      return;
    }

    switch (role.toLowerCase()) {
      case 'waiter':
        developer.log(
          'Navigating to Waiter Dashboard for: $userName',
          name: 'LoginController.Navigation',
        );
        NavigationService.goToWaiterDashboard();
        break;
      case 'chef':
        developer.log(
          'Navigating to Chef Dashboard for: $userName',
          name: 'LoginController.Navigation',
        );
        NavigationService.goToChefDashboard();
        break;
      default:
        developer.log(
          'Unknown role: $role for $userName, staying on login',
          name: 'LoginController.Navigation',
        );
        NavigationService.goToLogin();
        break;
    }
  }

  // UI Methods
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    developer.log(
      'Password visibility toggled: ${isPasswordVisible.value}',
      name: 'LoginController.UI',
    );
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    developer.log(
      'Remember me toggled: ${rememberMe.value}',
      name: 'LoginController.UI',
    );
  }

  // Validation Methods
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Submit login with Socket Connection Manager
  Future<void> submitLogin(context) async {
    try {
      if (!formKey.currentState!.validate()) {
        developer.log(
          'Form validation failed',
          name: 'LoginController.Validation',
        );
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final username = usernameController.text.trim();
      final password = passwordController.text;

      developer.log(
        'Starting login for username: $username',
        name: 'LoginController',
      );

      // AuthRepository handles all data storage
      final apiResponse = await AuthRepository.login(
        username: username,
        password: password,
      );

      if (apiResponse.success && apiResponse.data != null) {
        loginResponse.value = apiResponse.data!;
        currentEmployee.value = apiResponse.data!.data.employee;

        final employee = apiResponse.data!.data.employee;
        final userRole = employee.designation;
        final userName = employee.employeeName;
        final organizationName = employee.organizationName;

        developer.log(
          'Authentication successful for $userName (Role: $userRole) at $organizationName',
          name: 'LoginController.Auth',
        );

        // ✅ Connect socket after successful login
        try {
          developer.log('🔌 Connecting socket after login...', name: 'LoginController.Socket');

          final authData = await TokenManager.checkAuthenticationWithRole();
          final connected = await _socketManager.connectFromAuthData(authData);

          if (connected) {
            developer.log('✅ Socket connected successfully', name: 'LoginController.Socket');
          } else {
            developer.log('⚠️ Socket connection failed', name: 'LoginController.Socket');
          }
        } catch (socketError) {
          developer.log(
            '❌ Socket connection error: $socketError',
            name: 'LoginController.Socket',
          );
          // Don't block login if socket fails
        }

        // Success handling
        SnackBarUtil.showSuccess(
          context,
          'Welcome back, $userName!\nLogged in to $organizationName',
          title: 'Login Successful!',
          duration: const Duration(seconds: 3),
        );

        // Navigate based on role
        _navigateByRole(userRole, userName);
      } else {
        final errorMsg = apiResponse.errorMessage ?? 'Login failed';
        developer.log(
          'Authentication failed: $errorMsg',
          name: 'LoginController.Auth',
        );

        errorMessage.value = errorMsg;
        SnackBarUtil.showError(
          context,
          errorMsg,
          title: 'Login Failed',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      developer.log(
        'Login submission error: ${e.toString()}',
        name: 'LoginController.Error',
      );

      errorMessage.value = e.toString();
      SnackBarUtil.showError(
        context,
        'An unexpected error occurred. Please try again.',
        title: 'Error',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation Methods
  void navigateToForgotPassword(BuildContext context) {
    developer.log(
      'Navigating to forgot password',
      name: 'LoginController.Navigation',
    );
    context.go('/forgot-password');
  }

  // 🔥 FIXED: Logout method with proper cleanup
  Future<void> logout({bool sessionExpired = false}) async {
    try {
      // 🔥 FIX: Set the flag BEFORE starting logout
      _isLoggingOut = true;

      developer.log(
        'Logging out user (sessionExpired: $sessionExpired)',
        name: 'LoginController.Auth',
      );

      // Step 1: Disconnect socket first (now properly awaited)
      await _socketManager.disconnect();
      developer.log('✅ Socket disconnected', name: 'LoginController.Auth');

      // Step 2: Clear repository data (this clears storage)
      await AuthRepository.logout();
      developer.log('✅ Auth data cleared', name: 'LoginController.Auth');

      // Step 3: Clear controller data
      clearAuthData();
      developer.log('✅ Controller data cleared', name: 'LoginController.Auth');

      // 🔥 FIX: Wait a bit to ensure storage operations complete
      await Future.delayed(Duration(milliseconds: 150));

      // 🔥 FIX: Verify logout was successful by checking token
      final token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        developer.log(
          '⚠️ WARNING: Token still exists after logout! Force clearing...',
          name: 'LoginController.Auth',
        );
        // Force clear again
        await AuthRepository.logout();
        await Future.delayed(Duration(milliseconds: 100));
      }

      developer.log(
        '✅ User logged out successfully',
        name: 'LoginController.Auth',
      );

      // Step 4: Navigate to login
      NavigationService.goToLogin();

    } catch (e) {
      developer.log(
        'Logout error: ${e.toString()}',
        name: 'LoginController.Error',
      );
      // Even if there's an error, reset flag and navigate to login
      _isLoggingOut = false;
      NavigationService.goToLogin();
    }
  }

  /// Get socket connection status
  bool get socketConnected => _socketManager.connectionStatus;

  /// Reconnect socket manually (if needed)
  Future<void> reconnectSocket() async {
    final authData = await TokenManager.checkAuthenticationWithRole();
    if (authData['isAuthenticated']) {
      await _socketManager.connectFromAuthData(authData);
    }
  }
}