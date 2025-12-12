import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class TokenManager {
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _tokenExpirationKey = 'token_expiration';
  static const Duration _defaultExpirationDuration = Duration(days: 30);

  // Navigation flag to prevent multiple calls
  static bool _isNavigating = false;
  static Timer? _tokenExpirationTimer;

  /// Save token with user data and optional expiration time
  static Future<void> saveToken({
    required String token,
    String? userId,
    String? userRole, // NEW: Added role parameter
    String? userName, // NEW: Added name parameter
    String? expirationTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save token
      await prefs.setString(_tokenKey, token);

      // Save user ID if provided
      if (userId != null) {
        await prefs.setString(_userIdKey, userId);
      }

      // NEW: Save user role if provided
      if (userRole != null) {
        await prefs.setString(_userRoleKey, userRole);
      }

      // NEW: Save user name if provided
      if (userName != null) {
        await prefs.setString(_userNameKey, userName);
      }

      // Set expiration time
      if (expirationTime != null) {
        await prefs.setString(_tokenExpirationKey, expirationTime);
      } else {
        final defaultExpirationTime = DateTime.now().add(_defaultExpirationDuration).toIso8601String();
        await prefs.setString(_tokenExpirationKey, defaultExpirationTime);
      }

      developer.log('Token and user data saved successfully',
          name: 'TokenManager');
    } catch (e) {
      developer.log('Error saving token: $e', name: 'TokenManager.Error');
    }
  }

  /// Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      developer.log('Error getting token: $e', name: 'TokenManager.Error');
      return null;
    }
  }

  /// Get stored user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      developer.log('Error getting user ID: $e', name: 'TokenManager.Error');
      return null;
    }
  }

  /// NEW: Get stored user role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (e) {
      developer.log('Error getting user role: $e', name: 'TokenManager.Error');
      return null;
    }
  }

  /// NEW: Get stored user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      developer.log('Error getting user name: $e', name: 'TokenManager.Error');
      return null;
    }
  }

  /// NEW: Get complete user data
  static Future<Map<String, String?>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'token': prefs.getString(_tokenKey),
        'userId': prefs.getString(_userIdKey),
        'userRole': prefs.getString(_userRoleKey),
        'userName': prefs.getString(_userNameKey),
      };
    } catch (e) {
      developer.log('Error getting user data: $e', name: 'TokenManager.Error');
      return {
        'token': null,
        'userId': null,
        'userRole': null,
        'userName': null,
      };
    }
  }

  /// Check if user has a valid token
  static Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      return !await isTokenExpired();
    } catch (e) {
      developer.log('Error checking valid token: $e',
          name: 'TokenManager.Error');
      return false;
    }
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      // First check if user has a token
      final token = await getToken();
      if (token == null || token.isEmpty) {
        developer.log('No token found', name: 'TokenManager');
        return true;
      }

      final prefs = await SharedPreferences.getInstance();
      final expirationTimeString = prefs.getString(_tokenExpirationKey);

      if (expirationTimeString == null) {
        developer.log('No expiration time found, setting default expiration',
            name: 'TokenManager');
        // Set default expiration if not found
        final defaultExpirationTime =
            DateTime.now().add(_defaultExpirationDuration).toIso8601String();
        await prefs.setString(_tokenExpirationKey, defaultExpirationTime);
        return false; // Token is valid with new expiration
      }

      final expirationTime = DateTime.parse(expirationTimeString);
      final currentTime = DateTime.now();
      final isExpired = currentTime.isAfter(expirationTime);

      developer.log('Token expired: $isExpired', name: 'TokenManager');
      return isExpired;
    } catch (e) {
      developer.log('Error checking token expiration: $e',
          name: 'TokenManager.Error');
      return true; // Consider expired if can't parse
    }
  }

  /// NEW: Check authentication with role-based routing
  static Future<Map<String, dynamic>> checkAuthenticationWithRole() async {
    try {
      final isAuthenticated = await hasValidToken();

      if (isAuthenticated) {
        final userData = await getUserData();
        return {
          'isAuthenticated': true,
          'userRole': userData['userRole'],
          'userName': userData['userName'],
          'userId': userData['userId'],
        };
      }

      return {
        'isAuthenticated': false,
        'userRole': null,
        'userName': null,
        'userId': null,
      };
    } catch (e) {
      developer.log('Error checking authentication with role: $e',
          name: 'TokenManager.Error');
      return {
        'isAuthenticated': false,
        'userRole': null,
        'userName': null,
        'userId': null,
      };
    }
  }

  /// Check token and execute callbacks based on status
  static Future<void> checkTokenStatus({
    required Function() onTokenValid,
    required Function() onTokenInvalid,
    bool preventMultipleCalls = true,
  }) async {
    // Prevent multiple calls if flag is set
    if (preventMultipleCalls && _isNavigating) {
      developer.log('Token check already in progress, skipping...',
          name: 'TokenManager');
      return;
    }

    try {
      if (preventMultipleCalls) _isNavigating = true;

      if (await hasValidToken()) {
        developer.log('Token is valid', name: 'TokenManager');
        onTokenValid();
      } else {
        developer.log('Token is invalid or expired', name: 'TokenManager');
        onTokenInvalid();
      }
    } catch (e) {
      developer.log('Error during token check: $e', name: 'TokenManager.Error');
      onTokenInvalid();
    } finally {
      if (preventMultipleCalls) {
        // Reset navigation flag after delay
        Future.delayed(Duration(seconds: 1), () {
          _isNavigating = false;
        });
      }
    }
  }

  /// Refresh token expiration time
  static Future<void> refreshTokenExpiration({
    Duration? newDuration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final duration = newDuration ?? _defaultExpirationDuration;
      final newExpirationTime = DateTime.now().add(duration).toIso8601String();
      await prefs.setString(_tokenExpirationKey, newExpirationTime);
      developer.log('Token expiration refreshed', name: 'TokenManager');
    } catch (e) {
      developer.log('Error refreshing token expiration: $e',
          name: 'TokenManager.Error');
    }
  }

  /// Start periodic token expiration checking
  static void startTokenExpirationTimer({
    Duration interval = const Duration(minutes: 5),
    required Function() onTokenExpired,
  }) {
    stopTokenExpirationTimer(); // Cancel if already running

    _tokenExpirationTimer = Timer.periodic(interval, (timer) async {
      if (!_isNavigating && await isTokenExpired()) {
        developer.log('Token expired during periodic check',
            name: 'TokenManager');
        onTokenExpired();
      }
    });

    developer.log('Token expiration timer started', name: 'TokenManager');
  }

  /// Stop token expiration timer
  static void stopTokenExpirationTimer() {
    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = null;
    developer.log('Token expiration timer stopped', name: 'TokenManager');
  }

  /// Clear all stored authentication data
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userRoleKey); // NEW: Clear role
      await prefs.remove(_userNameKey); // NEW: Clear name
      await prefs.remove(_tokenExpirationKey);

      // Reset navigation flag
      _isNavigating = false;

      developer.log('Auth data cleared successfully', name: 'TokenManager');
    } catch (e) {
      developer.log('Error clearing auth data: $e', name: 'TokenManager.Error');
    }
  }

  /// Get token expiration time
  static Future<DateTime?> getTokenExpirationTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationString = prefs.getString(_tokenExpirationKey);
      if (expirationString != null) {
        return DateTime.parse(expirationString);
      }
      return null;
    } catch (e) {
      developer.log('Error getting expiration time: $e',
          name: 'TokenManager.Error');
      return null;
    }
  }

  /// Check if user is logged in (has token, regardless of expiration)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get remaining token time
  static Future<Duration?> getRemainingTokenTime() async {
    try {
      final expirationTime = await getTokenExpirationTime();
      if (expirationTime != null) {
        final currentTime = DateTime.now();
        if (currentTime.isBefore(expirationTime)) {
          return expirationTime.difference(currentTime);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting remaining time: $e',
          name: 'TokenManager.Error');
      return null;
    }
  }
}
