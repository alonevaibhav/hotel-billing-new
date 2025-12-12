//
//
// import 'dart:developer' as developer;
// import 'dart:async';
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
//   Timer? _connectionTimeout;
//
//   // ✅ Store connection params for auto-reconnect
//   Map<String, dynamic>? _lastConnectionParams;
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
//     // ✅ Store connection params for reconnection
//     _lastConnectionParams = {
//       'serverUrl': serverUrl,
//       'hotelOwnerId': hotelOwnerId,
//       'role': role,
//       'userId': userId,
//       'employeeName': employeeName,
//       'authToken': authToken,
//     };
//
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
//       while (_connectionInProgress && attempts < 20) { // Increased wait time
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
//       // ✅ Set connection timeout
//       _connectionTimeout = Timer(Duration(seconds: 10), () {
//         if (!_socketService.isConnected) {
//           developer.log(
//             '⏰ Connection timeout - socket did not connect within 10 seconds',
//             name: 'SocketConnectionManager',
//           );
//           _connectionInProgress = false;
//         }
//       });
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
//       // ✅ Setup connection state listeners
//       _setupConnectionStateListeners();
//
//       // ✅ Wait for connection with proper timeout
//       int waitAttempts = 0;
//       while (!_socketService.isConnected && waitAttempts < 30) {
//         await Future.delayed(Duration(milliseconds: 200));
//         waitAttempts++;
//       }
//
//       isConnected.value = _socketService.isConnected;
//
//       if (isConnected.value) {
//         developer.log(
//           '✅ Socket connection successful after ${waitAttempts * 200}ms',
//           name: 'SocketConnectionManager',
//         );
//       } else {
//         developer.log(
//           '⚠️ Socket initiated but not connected after ${waitAttempts * 200}ms. Check server availability.',
//           name: 'SocketConnectionManager',
//         );
//       }
//
//       return isConnected.value;
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Socket connection failed: $e\n$stackTrace',
//         name: 'SocketConnectionManager',
//       );
//       isConnected.value = false;
//       return false;
//     } finally {
//       _connectionTimeout?.cancel();
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
//   /// Setup connection state listeners
//   void _setupConnectionStateListeners() {
//     // ✅ Remove old listeners to prevent duplicates
//     _socketService.off('authenticated');
//     _socketService.off('authentication_error');
//
//     // Listen to authentication events
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
//
//       // ✅ Attempt auto-reconnect on auth failure
//       _attemptAutoReconnect();
//     });
//
//     // ✅ Monitor socket connection state changes
//     ever(isConnected, (connected) {
//       developer.log(
//         '🔄 Connection state changed: $connected',
//         name: 'SocketConnectionManager',
//       );
//
//       if (!connected) {
//         _attemptAutoReconnect();
//       }
//     });
//   }
//
//   /// ✅ NEW: Auto-reconnect logic
//   Timer? _reconnectTimer;
//   int _reconnectAttempts = 0;
//   final _maxReconnectAttempts = 5;
//
//   void _attemptAutoReconnect() {
//     if (_lastConnectionParams == null || _reconnectAttempts >= _maxReconnectAttempts) {
//       return;
//     }
//
//     _reconnectTimer?.cancel();
//     _reconnectAttempts++;
//
//     final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff
//
//     developer.log(
//       '🔄 Scheduling auto-reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
//       name: 'SocketConnectionManager',
//     );
//
//     _reconnectTimer = Timer(delay, () async {
//       if (!_socketService.isConnected) {
//         developer.log(
//           '🔄 Auto-reconnect attempt $_reconnectAttempts',
//           name: 'SocketConnectionManager',
//         );
//
//         final params = _lastConnectionParams!;
//         await connect(
//           serverUrl: params['serverUrl'],
//           hotelOwnerId: params['hotelOwnerId'],
//           role: params['role'],
//           userId: params['userId'],
//           employeeName: params['employeeName'],
//           authToken: params['authToken'],
//         );
//       }
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
//     _reconnectTimer?.cancel();
//     _connectionTimeout?.cancel();
//     _reconnectAttempts = 0;
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
//   Future<bool> reconnect() async {
//     if (_lastConnectionParams == null) {
//       developer.log(
//         '⚠️ Cannot reconnect - no previous connection params',
//         name: 'SocketConnectionManager',
//       );
//       return false;
//     }
//
//     developer.log(
//       '🔄 Reconnecting socket...',
//       name: 'SocketConnectionManager',
//     );
//
//     disconnect();
//     await Future.delayed(Duration(milliseconds: 1000)); // Wait before reconnecting
//
//     final params = _lastConnectionParams!;
//     return await connect(
//       serverUrl: params['serverUrl'],
//       hotelOwnerId: params['hotelOwnerId'],
//       role: params['role'],
//       userId: params['userId'],
//       employeeName: params['employeeName'],
//       authToken: params['authToken'],
//     );
//   }
//
//   /// ✅ NEW: Force re-register all listeners (useful after connection issues)
//   void forceReregisterListeners() {
//     developer.log(
//       '🔧 Forcing re-registration of all socket listeners',
//       name: 'SocketConnectionManager',
//     );
//     _socketService.forceReregisterListeners();
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
//       'reconnectAttempts': _reconnectAttempts,
//       'hasStoredParams': _lastConnectionParams != null,
//     };
//   }
//
//   /// Reset connection state
//   void resetConnectionState() {
//     _connectionInProgress = false;
//     _reconnectAttempts = 0;
//     _reconnectTimer?.cancel();
//     _connectionTimeout?.cancel();
//     isConnected.value = _socketService.isConnected;
//
//     developer.log(
//       '🔄 Connection state reset. Current status: ${getConnectionInfo()}',
//       name: 'SocketConnectionManager',
//     );
//   }
//
//   @override
//   void onClose() {
//     _reconnectTimer?.cancel();
//     _connectionTimeout?.cancel();
//     disconnect();
//     super.onClose();
//   }
// }


import 'dart:developer' as developer;
import 'dart:async';
import 'package:get/get.dart';
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
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

    // 🔥 Get token from ApiService
    final authToken = await ApiService.getToken();
    if (authToken == null) {
      developer.log(
        '⚠️ No auth token found in ApiService.getToken()',
        name: 'SocketConnectionManager',
      );
      return false;
    }

    final serverUrl = ApiConstants.socketBaseUrl;
    final hotelOwnerId = employeeData['hotelOwnerId'] ?? 0;
    final role = authData['userRole'] ?? 'waiter';
    final userId = employeeData['id'] ?? 0;
    final employeeName = authData['userName'] ?? 'User';

    // 🔥 Debug Log all values
    developer.log(
      '''
---- SOCKET CONNECT PARAMS ----
serverUrl      : $serverUrl
hotelOwnerId   : $hotelOwnerId
role           : $role
userId         : $userId
employeeName   : $employeeName
authToken      : $authToken
--------------------------------
''',
      name: 'SocketConnectionManager',
    );

    return await connect(
      serverUrl: serverUrl,
      hotelOwnerId: hotelOwnerId,
      role: role,
      userId: userId,
      employeeName: employeeName,
      authToken: authToken, // <-- Token now from ApiService
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

      // ✅ Attempt auto-reconnect on auth failure (only if we have valid params)
      if (_lastConnectionParams != null) {
        _attemptAutoReconnect();
      }
    });

    // ✅ Monitor socket connection state changes
    ever(isConnected, (connected) {
      developer.log(
        '🔄 Connection state changed: $connected',
        name: 'SocketConnectionManager',
      );

      if (!connected && _lastConnectionParams != null) {
        _attemptAutoReconnect();
      }
    });
  }

  /// ✅ Auto-reconnect logic
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final _maxReconnectAttempts = 5;

  void _attemptAutoReconnect() {
    // 🔥 FIX: Don't reconnect if params are cleared (after logout)
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
      // 🔥 FIX: Double-check params still exist before reconnecting
      if (_lastConnectionParams == null) {
        developer.log(
          '❌ Reconnect cancelled - connection params cleared',
          name: 'SocketConnectionManager',
        );
        return;
      }

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

  /// 🔥 FIXED: Disconnect socket and clear reconnection params
  Future<void> disconnect() async {
    developer.log(
      '🔌 Disconnecting socket...',
      name: 'SocketConnectionManager',
    );

    // 🔥 FIX: Cancel timers first
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connectionTimeout?.cancel();
    _connectionTimeout = null;

    // 🔥 FIX: Clear connection params to prevent auto-reconnect
    _lastConnectionParams = null;
    _reconnectAttempts = 0;

    developer.log(
      '✅ Reconnect timers canceled and params cleared',
      name: 'SocketConnectionManager',
    );

    // Disconnect the socket
    _socketService.disconnect();
    isConnected.value = false;
    _connectionInProgress = false;

    // 🔥 FIX: Add small delay to ensure disconnect completes
    await Future.delayed(Duration(milliseconds: 100));

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

    // Cancel any pending reconnect attempts
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;

    // Disconnect first
    _socketService.disconnect();
    isConnected.value = false;
    _connectionInProgress = false;

    await Future.delayed(Duration(milliseconds: 1000)); // Wait before reconnecting

    // Reconnect with stored params
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

  /// ✅ Force re-register all listeners (useful after connection issues)
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
    _lastConnectionParams = null; // 🔥 FIX: Clear params on close
    disconnect();
    super.onClose();
  }
}