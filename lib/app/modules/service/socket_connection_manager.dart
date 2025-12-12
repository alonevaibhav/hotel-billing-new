// // lib/app/core/services/socket_connection_manager.dart
// import 'dart:developer' as developer;
// import 'package:get/get.dart';
// import '../../core/constants/api_constant.dart';
// import '../../core/services/socket_service.dart';
// import '../../core/services/storage_service.dart';
//
// /// Manages socket connections to prevent duplicates and handle connection lifecycle
// class SocketConnectionManager extends GetxService {
//   static SocketConnectionManager get instance => Get.find<SocketConnectionManager>();
//
//   final SocketService _socketService = SocketService.instance;
//   final isConnected = false.obs;
//
//   // ✅ Track connection attempts to prevent duplicates
//   bool _connectionInProgress = false;
//
//   /// Initialize the socket connection manager
//   static Future<SocketConnectionManager> init() async {
//     final manager = SocketConnectionManager();
//     Get.put(manager);
//     return manager;
//   }
//
//   /// Connect to socket with duplicate prevention
//   Future<bool> connect({
//     required String serverUrl,
//     required int hotelOwnerId,
//     required String role,
//     required int userId,
//     required String employeeName,
//     String? authToken,
//   }) async {
//     // ✅ Prevent duplicate connections
//     if (_socketService.isConnected) {
//       developer.log(
//         '✅ Socket already connected, skipping duplicate connection',
//         name: 'SocketConnectionManager',
//       );
//       isConnected.value = true;
//       return true;
//     }
//
//     // ✅ Prevent concurrent connection attempts
//     if (_connectionInProgress) {
//       developer.log(
//         '⚠️ Connection already in progress, waiting...',
//         name: 'SocketConnectionManager',
//       );
//
//       // Wait for existing connection attempt to complete
//       int attempts = 0;
//       while (_connectionInProgress && attempts < 10) {
//         await Future.delayed(Duration(milliseconds: 500));
//         attempts++;
//       }
//
//       isConnected.value = _socketService.isConnected;
//       return _socketService.isConnected;
//     }
//
//     try {
//       _connectionInProgress = true;
//
//       developer.log(
//         '🔌 Initiating socket connection...',
//         name: 'SocketConnectionManager',
//       );
//
//       await _socketService.connect(
//         serverUrl: serverUrl,
//         hotelOwnerId: hotelOwnerId,
//         role: role,
//         userId: userId,
//         employeeName: employeeName,
//         authToken: authToken,
//       );
//
//       // ✅ Setup connection state listeners (not duplicate event listeners)
//       _setupConnectionStateListeners();
//
//       // Wait for connection to establish
//       await Future.delayed(Duration(milliseconds: 1500));
//
//       isConnected.value = _socketService.isConnected;
//
//       if (isConnected.value) {
//         developer.log(
//           '✅ Socket connection successful',
//           name: 'SocketConnectionManager',
//         );
//       } else {
//         developer.log(
//           '⚠️ Socket initiated but not yet connected. Check backend server.',
//           name: 'SocketConnectionManager',
//         );
//       }
//
//       return isConnected.value;
//     } catch (e) {
//       developer.log(
//         '❌ Socket connection failed: $e',
//         name: 'SocketConnectionManager',
//       );
//       isConnected.value = false;
//       return false;
//     } finally {
//       _connectionInProgress = false;
//     }
//   }
//
//   /// Connect using stored authentication data
//   Future<bool> connectFromAuthData(Map<String, dynamic> authData) async {
//     if (!authData['isAuthenticated']) {
//       developer.log(
//         '⚠️ User not authenticated, cannot connect socket',
//         name: 'SocketConnectionManager',
//       );
//       return false;
//     }
//
//     final employeeData = StorageService.to.getEmployeeData();
//
//     if (employeeData == null) {
//       developer.log(
//         '⚠️ No employee data found, cannot connect socket',
//         name: 'SocketConnectionManager',
//       );
//       return false;
//     }
//
//     return await connect(
//       serverUrl: ApiConstants.socketBaseUrl,
//       hotelOwnerId: employeeData['hotelOwnerId'] ?? 0,
//       role: authData['userRole'] ?? 'waiter',
//       userId: employeeData['id'] ?? 0,
//       employeeName: authData['userName'] ?? 'User',
//       authToken: authData['token'],
//     );
//   }
//
//   /// Setup connection state listeners (only for state management, not socket events)
//   void _setupConnectionStateListeners() {
//     // Listen to high-level connection events for state updates
//     _socketService.on('authenticated', (data) {
//       isConnected.value = true;
//       developer.log(
//         '✅ Connection authenticated',
//         name: 'SocketConnectionManager',
//       );
//     });
//
//     _socketService.on('authentication_error', (data) {
//       isConnected.value = false;
//       developer.log(
//         '❌ Authentication failed: $data',
//         name: 'SocketConnectionManager',
//       );
//     });
//   }
//
//   /// Disconnect socket
//   void disconnect() {
//     if (!_socketService.isConnected) {
//       developer.log(
//         '⚠️ Socket already disconnected',
//         name: 'SocketConnectionManager',
//       );
//       return;
//     }
//
//     developer.log(
//       '🔌 Disconnecting socket...',
//       name: 'SocketConnectionManager',
//     );
//
//     _socketService.disconnect();
//     isConnected.value = false;
//     _connectionInProgress = false;
//
//     developer.log(
//       '✅ Socket disconnected successfully',
//       name: 'SocketConnectionManager',
//     );
//   }
//
//   /// Reconnect socket (disconnect and connect again)
//   Future<bool> reconnect({
//     required String serverUrl,
//     required int hotelOwnerId,
//     required String role,
//     required int userId,
//     required String employeeName,
//     String? authToken,
//   }) async {
//     developer.log(
//       '🔄 Reconnecting socket...',
//       name: 'SocketConnectionManager',
//     );
//
//     disconnect();
//     await Future.delayed(Duration(milliseconds: 1000)); // Wait before reconnecting
//
//     return await connect(
//       serverUrl: serverUrl,
//       hotelOwnerId: hotelOwnerId,
//       role: role,
//       userId: userId,
//       employeeName: employeeName,
//       authToken: authToken,
//     );
//   }
//
//   /// Check if socket is connected
//   bool get connectionStatus => _socketService.isConnected;
//
//   /// Get the underlying socket service
//   SocketService get socketService => _socketService;
//
//   /// Get detailed connection information
//   Map<String, dynamic> getConnectionInfo() {
//     final info = _socketService.getConnectionInfo();
//     return {
//       ...info,
//       'managerConnected': isConnected.value,
//       'connectionInProgress': _connectionInProgress,
//     };
//   }
//
//   /// Reset connection state (useful for debugging/testing)
//   void resetConnectionState() {
//     _connectionInProgress = false;
//     isConnected.value = _socketService.isConnected;
//     developer.log(
//       '🔄 Connection state reset. Current status: ${getConnectionInfo()}',
//       name: 'SocketConnectionManager',
//     );
//   }
// }


import 'dart:developer' as developer;
import 'dart:async';
import 'package:get/get.dart';
import '../../core/constants/api_constant.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/storage_service.dart';

/// Manages socket connections to prevent duplicates and handle connection lifecycle
class SocketConnectionManager extends GetxService {
  static SocketConnectionManager get instance => Get.find<SocketConnectionManager>();

  final SocketService _socketService = SocketService.instance;
  final isConnected = false.obs;

  // ✅ Track connection attempts to prevent duplicates
  bool _connectionInProgress = false;
  Timer? _connectionTimeout;

  // ✅ Store connection params for auto-reconnect
  Map<String, dynamic>? _lastConnectionParams;

  /// Initialize the socket connection manager
  static Future<SocketConnectionManager> init() async {
    final manager = SocketConnectionManager();
    Get.put(manager);
    return manager;
  }

  /// Connect to socket with duplicate prevention
  Future<bool> connect({
    required String serverUrl,
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
    String? authToken,
  }) async {
    // ✅ Store connection params for reconnection
    _lastConnectionParams = {
      'serverUrl': serverUrl,
      'hotelOwnerId': hotelOwnerId,
      'role': role,
      'userId': userId,
      'employeeName': employeeName,
      'authToken': authToken,
    };

    // ✅ Prevent duplicate connections
    if (_socketService.isConnected) {
      developer.log(
        '✅ Socket already connected, skipping duplicate connection',
        name: 'SocketConnectionManager',
      );
      isConnected.value = true;
      return true;
    }

    // ✅ Prevent concurrent connection attempts
    if (_connectionInProgress) {
      developer.log(
        '⚠️ Connection already in progress, waiting...',
        name: 'SocketConnectionManager',
      );

      // Wait for existing connection attempt to complete
      int attempts = 0;
      while (_connectionInProgress && attempts < 20) { // Increased wait time
        await Future.delayed(Duration(milliseconds: 500));
        attempts++;
      }

      isConnected.value = _socketService.isConnected;
      return _socketService.isConnected;
    }

    try {
      _connectionInProgress = true;

      // ✅ Set connection timeout
      _connectionTimeout = Timer(Duration(seconds: 10), () {
        if (!_socketService.isConnected) {
          developer.log(
            '⏰ Connection timeout - socket did not connect within 10 seconds',
            name: 'SocketConnectionManager',
          );
          _connectionInProgress = false;
        }
      });

      developer.log(
        '🔌 Initiating socket connection...',
        name: 'SocketConnectionManager',
      );

      await _socketService.connect(
        serverUrl: serverUrl,
        hotelOwnerId: hotelOwnerId,
        role: role,
        userId: userId,
        employeeName: employeeName,
        authToken: authToken,
      );

      // ✅ Setup connection state listeners
      _setupConnectionStateListeners();

      // ✅ Wait for connection with proper timeout
      int waitAttempts = 0;
      while (!_socketService.isConnected && waitAttempts < 30) {
        await Future.delayed(Duration(milliseconds: 200));
        waitAttempts++;
      }

      isConnected.value = _socketService.isConnected;

      if (isConnected.value) {
        developer.log(
          '✅ Socket connection successful after ${waitAttempts * 200}ms',
          name: 'SocketConnectionManager',
        );
      } else {
        developer.log(
          '⚠️ Socket initiated but not connected after ${waitAttempts * 200}ms. Check server availability.',
          name: 'SocketConnectionManager',
        );
      }

      return isConnected.value;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Socket connection failed: $e\n$stackTrace',
        name: 'SocketConnectionManager',
      );
      isConnected.value = false;
      return false;
    } finally {
      _connectionTimeout?.cancel();
      _connectionInProgress = false;
    }
  }

  /// Connect using stored authentication data
  Future<bool> connectFromAuthData(Map<String, dynamic> authData) async {
    if (!authData['isAuthenticated']) {
      developer.log(
        '⚠️ User not authenticated, cannot connect socket',
        name: 'SocketConnectionManager',
      );
      return false;
    }

    final employeeData = StorageService.to.getEmployeeData();

    if (employeeData == null) {
      developer.log(
        '⚠️ No employee data found, cannot connect socket',
        name: 'SocketConnectionManager',
      );
      return false;
    }

    return await connect(
      serverUrl: ApiConstants.socketBaseUrl,
      hotelOwnerId: employeeData['hotelOwnerId'] ?? 0,
      role: authData['userRole'] ?? 'waiter',
      userId: employeeData['id'] ?? 0,
      employeeName: authData['userName'] ?? 'User',
      authToken: authData['token'],
    );
  }

  /// Setup connection state listeners
  void _setupConnectionStateListeners() {
    // ✅ Remove old listeners to prevent duplicates
    _socketService.off('authenticated');
    _socketService.off('authentication_error');

    // Listen to authentication events
    _socketService.on('authenticated', (data) {
      isConnected.value = true;
      developer.log(
        '✅ Connection authenticated',
        name: 'SocketConnectionManager',
      );
    });

    _socketService.on('authentication_error', (data) {
      isConnected.value = false;
      developer.log(
        '❌ Authentication failed: $data',
        name: 'SocketConnectionManager',
      );

      // ✅ Attempt auto-reconnect on auth failure
      _attemptAutoReconnect();
    });

    // ✅ Monitor socket connection state changes
    ever(isConnected, (connected) {
      developer.log(
        '🔄 Connection state changed: $connected',
        name: 'SocketConnectionManager',
      );

      if (!connected) {
        _attemptAutoReconnect();
      }
    });
  }

  /// ✅ NEW: Auto-reconnect logic
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final _maxReconnectAttempts = 5;

  void _attemptAutoReconnect() {
    if (_lastConnectionParams == null || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff

    developer.log(
      '🔄 Scheduling auto-reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
      name: 'SocketConnectionManager',
    );

    _reconnectTimer = Timer(delay, () async {
      if (!_socketService.isConnected) {
        developer.log(
          '🔄 Auto-reconnect attempt $_reconnectAttempts',
          name: 'SocketConnectionManager',
        );

        final params = _lastConnectionParams!;
        await connect(
          serverUrl: params['serverUrl'],
          hotelOwnerId: params['hotelOwnerId'],
          role: params['role'],
          userId: params['userId'],
          employeeName: params['employeeName'],
          authToken: params['authToken'],
        );
      }
    });
  }

  /// Disconnect socket
  void disconnect() {
    if (!_socketService.isConnected) {
      developer.log(
        '⚠️ Socket already disconnected',
        name: 'SocketConnectionManager',
      );
      return;
    }

    developer.log(
      '🔌 Disconnecting socket...',
      name: 'SocketConnectionManager',
    );

    _reconnectTimer?.cancel();
    _connectionTimeout?.cancel();
    _reconnectAttempts = 0;

    _socketService.disconnect();
    isConnected.value = false;
    _connectionInProgress = false;

    developer.log(
      '✅ Socket disconnected successfully',
      name: 'SocketConnectionManager',
    );
  }

  /// Reconnect socket (disconnect and connect again)
  Future<bool> reconnect() async {
    if (_lastConnectionParams == null) {
      developer.log(
        '⚠️ Cannot reconnect - no previous connection params',
        name: 'SocketConnectionManager',
      );
      return false;
    }

    developer.log(
      '🔄 Reconnecting socket...',
      name: 'SocketConnectionManager',
    );

    disconnect();
    await Future.delayed(Duration(milliseconds: 1000)); // Wait before reconnecting

    final params = _lastConnectionParams!;
    return await connect(
      serverUrl: params['serverUrl'],
      hotelOwnerId: params['hotelOwnerId'],
      role: params['role'],
      userId: params['userId'],
      employeeName: params['employeeName'],
      authToken: params['authToken'],
    );
  }

  /// ✅ NEW: Force re-register all listeners (useful after connection issues)
  void forceReregisterListeners() {
    developer.log(
      '🔧 Forcing re-registration of all socket listeners',
      name: 'SocketConnectionManager',
    );
    _socketService.forceReregisterListeners();
  }

  /// Check if socket is connected
  bool get connectionStatus => _socketService.isConnected;

  /// Get the underlying socket service
  SocketService get socketService => _socketService;

  /// Get detailed connection information
  Map<String, dynamic> getConnectionInfo() {
    final info = _socketService.getConnectionInfo();
    return {
      ...info,
      'managerConnected': isConnected.value,
      'connectionInProgress': _connectionInProgress,
      'reconnectAttempts': _reconnectAttempts,
      'hasStoredParams': _lastConnectionParams != null,
    };
  }

  /// Reset connection state
  void resetConnectionState() {
    _connectionInProgress = false;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _connectionTimeout?.cancel();
    isConnected.value = _socketService.isConnected;

    developer.log(
      '🔄 Connection state reset. Current status: ${getConnectionInfo()}',
      name: 'SocketConnectionManager',
    );
  }

  @override
  void onClose() {
    _reconnectTimer?.cancel();
    _connectionTimeout?.cancel();
    disconnect();
    super.onClose();
  }
}