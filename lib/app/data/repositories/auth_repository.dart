//
// import 'dart:developer' as developer;
// import '../../core/constants/api_constant.dart';
// import '../../core/services/api_service.dart';
// import '../../core/services/session_manager_service.dart';
// import '../../core/services/storage_service.dart';
// import '../models/RequestModel/login_request_model.dart';
// import '../models/ResponseModel/login_response_model.dart';
//
// class AuthRepository {
//   /// Login user with username and password
//   static Future<ApiResponse<LoginResponseModel>> login({
//     required String username,
//     required String password,
//   }) async {
//     try {
//       developer.log('Starting login API call for username: $username',
//           name: 'AuthRepository');
//
//       final loginRequest = LoginRequestModel(
//         username: username,
//         password: password,
//       );
//
//       final response = await ApiService.post<LoginResponseModel>(
//         endpoint: ApiConstants.hostelBillingLogin,
//         body: loginRequest.toJson(),
//         fromJson: (json) => LoginResponseModel.fromJson(json),
//         includeToken: false,
//       );
//
//       developer.log('Login API response - Success: ${response.success}',
//           name: 'AuthRepository');
//
//       if (response.success && response.data != null) {
//         final employee = response.data!.data.employee;
//         final token = response.data!.data.token;
//         final uid = employee.id.toString();
//         final userRole = employee.designation;
//         final userName = employee.employeeName;
//         final organizationName = employee.organizationName;
//         final organizationAddress = employee.address;
//
//         // Store in ApiService (existing)
//         await ApiService.setToken(token);
//         await ApiService.setUid(uid);
//
//         // ✅ Store organization data in StorageService
//         StorageService.to.storeOrganizationData(
//           organizationName: organizationName ?? 'Hotel Name',
//           organizationAddress: organizationAddress ?? 'Hotel Address',
//           userName: userName ?? 'User',
//         );
//
//         // ✅ NEW: Store complete employee data in StorageService
//         StorageService.to.storeEmployeeData(
//           userId: employee.id,
//           hotelOwnerId: employee.hotelOwnerId, // Adjust if different field
//           employeeName: userName ?? 'User',
//           designation: userRole ?? 'waiter',
//           organizationName: organizationName ?? 'Hotel',
//         );
//
//         developer.log('==================== STORING EMPLOYEE DATA ====================',
//             name: 'EMPLOYEE_DATA');
//
//         developer.log('userId: ${employee.id}', name: 'EMPLOYEE_DATA');
//         developer.log('hotelOwnerId: ${employee.hotelOwnerId}', name: 'EMPLOYEE_DATA');
//         developer.log('employeeName: ${userName ?? 'User'}', name: 'EMPLOYEE_DATA');
//         developer.log('designation: ${userRole ?? 'waiter'}', name: 'EMPLOYEE_DATA');
//         developer.log('organizationName: ${organizationName ?? 'Hotel'}', name: 'EMPLOYEE_DATA');
//
//         developer.log('===============================================================',
//             name: 'EMPLOYEE_DATA');
//
//         // ✅ Store auth token in TokenManager (for token management only)
//         await TokenManager.saveToken(
//           token: token,
//           userId: uid,
//           userRole: userRole,
//           userName: userName,
//         );
//
//         developer.log(
//           '✅ All data stored - ID: $uid, Role: $userRole, Name: $userName',
//           name: 'AuthRepository',
//         );
//       }
//
//       return response;
//     } catch (e) {
//       developer.log('Login API call failed: ${e.toString()}',
//           name: 'AuthRepository.Error');
//
//       return ApiResponse<LoginResponseModel>(
//         success: false,
//         errorMessage: e.toString(),
//         statusCode: -1,
//       );
//     }
//   }
//
//   /// Logout user and clear stored data
//   static Future<void> logout() async {
//     try {
//       developer.log('Logging out user', name: 'AuthRepository');
//
//       // Clear stored authentication data from ApiService
//       await ApiService.clearAuthData();
//
//       // Clear from TokenManager
//       await TokenManager.clearAuthData();
//
//       // Stop token expiration timer if running
//       TokenManager.stopTokenExpirationTimer();
//
//       // ✅ Clear organization data from StorageService
//       StorageService.to.clearOrganizationData();
//
//       // ✅ NEW: Clear employee data from StorageService
//       StorageService.to.clearEmployeeData();
//
//       developer.log('User logged out successfully', name: 'AuthRepository');
//     } catch (e) {
//       developer.log('Logout error: ${e.toString()}',
//           name: 'AuthRepository.Error');
//     }
//   }
//
//   /// Get stored employee data (for socket connection, etc.)
//   static Map<String, dynamic>? getEmployeeData() {
//     return StorageService.to.getEmployeeData();
//   }
// }

import 'dart:developer' as developer;
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/session_manager_service.dart';
import '../../core/services/storage_service.dart';
import '../models/RequestModel/login_request_model.dart';
import '../models/ResponseModel/login_response_model.dart';

class AuthRepository {
  /// Login user with username and password
  static Future<ApiResponse<LoginResponseModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      developer.log('Starting login API call for username: $username',
          name: 'AuthRepository');

      final loginRequest = LoginRequestModel(
        username: username,
        password: password,
      );

      final response = await ApiService.post<LoginResponseModel>(
        endpoint: ApiConstants.hostelBillingLogin,
        body: loginRequest.toJson(),
        fromJson: (json) => LoginResponseModel.fromJson(json),
        includeToken: false,
      );

      developer.log('Login API response - Success: ${response.success}',
          name: 'AuthRepository');

      if (response.success && response.data != null) {
        final employee = response.data!.data.employee;
        final token = response.data!.data.token;
        final uid = employee.id.toString();
        final userRole = employee.designation;
        final userName = employee.employeeName;
        final organizationName = employee.organizationName;
        final organizationAddress = employee.ownerAddress;

        // Store in ApiService (existing)
        await ApiService.setToken(token);
        await ApiService.setUid(uid);

        // ✅ Store organization data in StorageService
        StorageService.to.storeOrganizationData(
          organizationName: organizationName ?? 'Hotel Name',
          organizationAddress: organizationAddress ?? 'Hotel Address',
          userName: userName ?? 'User',
        );

        // ✅ Store complete employee data in StorageService
        StorageService.to.storeEmployeeData(
          userId: employee.id,
          hotelOwnerId: employee.hotelOwnerId,
          employeeName: userName ?? 'User',
          designation: userRole ?? 'waiter',
          organizationName: organizationName ?? 'Hotel',
        );

        developer.log('==================== STORING EMPLOYEE DATA ====================',
            name: 'EMPLOYEE_DATA');

        developer.log('userId: ${employee.id}', name: 'EMPLOYEE_DATA');
        developer.log('hotelOwnerId: ${employee.hotelOwnerId}', name: 'EMPLOYEE_DATA');
        developer.log('employeeName: ${userName ?? 'User'}', name: 'EMPLOYEE_DATA');
        developer.log('designation: ${userRole ?? 'waiter'}', name: 'EMPLOYEE_DATA');
        developer.log('organizationName: ${organizationName ?? 'Hotel'}', name: 'EMPLOYEE_DATA');

        developer.log('===============================================================',
            name: 'EMPLOYEE_DATA');

        // ✅ Store auth token in TokenManager (for token management only)
        await TokenManager.saveToken(
          token: token,
          userId: uid,
          userRole: userRole,
          userName: userName,
        );

        developer.log(
          '✅ All data stored - ID: $uid, Role: $userRole, Name: $userName',
          name: 'AuthRepository',
        );
      }

      return response;
    } catch (e) {
      developer.log('Login API call failed: ${e.toString()}',
          name: 'AuthRepository.Error');

      return ApiResponse<LoginResponseModel>(
        success: false,
        errorMessage: e.toString(),
        statusCode: -1,
      );
    }
  }

  /// 🔥 NEW: Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await TokenManager.getToken();
      final employeeData = StorageService.to.getEmployeeData();

      final isAuth = token != null &&
          token.isNotEmpty &&
          employeeData != null;

      developer.log(
        'Auth check - Token exists: ${token != null}, Employee data exists: ${employeeData != null}',
        name: 'AuthRepository',
      );

      return isAuth;
    } catch (e) {
      developer.log(
        'Error checking authentication: $e',
        name: 'AuthRepository.Error',
      );
      return false;
    }
  }

  /// Logout user and clear stored data
  static Future<void> logout() async {
    try {
      developer.log('Logging out user', name: 'AuthRepository');

      // Clear stored authentication data from ApiService
      await ApiService.clearAuthData();

      // Clear from TokenManager
      await TokenManager.clearAuthData();

      // Stop token expiration timer if running
      TokenManager.stopTokenExpirationTimer();

      // ✅ Clear organization data from StorageService
      StorageService.to.clearOrganizationData();

      // ✅ Clear employee data from StorageService
      StorageService.to.clearEmployeeData();

      developer.log('User logged out successfully', name: 'AuthRepository');
    } catch (e) {
      developer.log('Logout error: ${e.toString()}',
          name: 'AuthRepository.Error');
      rethrow; // Re-throw so caller knows logout failed
    }
  }

  /// Get stored employee data (for socket connection, etc.)
  static Map<String, dynamic>? getEmployeeData() {
    return StorageService.to.getEmployeeData();
  }

  /// 🔥 NEW: Get user role
  static Future<String?> getUserRole() async {
    try {
      final authData = await TokenManager.checkAuthenticationWithRole();
      return authData['userRole'] as String?;
    } catch (e) {
      developer.log(
        'Error getting user role: $e',
        name: 'AuthRepository.Error',
      );
      return null;
    }
  }

  /// 🔥 NEW: Get user name
  static Future<String?> getUserName() async {
    try {
      final authData = await TokenManager.checkAuthenticationWithRole();
      return authData['userName'] as String?;
    } catch (e) {
      developer.log(
        'Error getting user name: $e',
        name: 'AuthRepository.Error',
      );
      return null;
    }
  }
}