//
//
// import 'dart:developer' as developer;
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class SocketService {
//   static SocketService? _instance;
//   IO.Socket? _socket;
//   bool _isConnected = false;
//
//   // Improved event listener management
//   final Map<String, List<Function>> _eventListeners = {};
//
//   static SocketService get instance {
//     _instance ??= SocketService._internal();
//     return _instance!;
//   }
//
//   SocketService._internal();
//
//   bool get isConnected => _isConnected;
//   IO.Socket? get socket => _socket;
//
//   /// Initialize and connect to socket server
//   Future<void> connect({
//     required String serverUrl,
//     required int hotelOwnerId,
//     required String role,
//     required int userId,
//     required String employeeName,
//     String? authToken,
//   }) async {
//     if (_socket != null && _isConnected) {
//       developer.log('Socket already connected', name: 'SOCKET_SERVICE');
//       return;
//     }
//
//     // Dispose existing socket if present
//     if (_socket != null) {
//       developer.log('Disposing existing socket instance', name: 'SOCKET_SERVICE');
//       _socket!.dispose();
//       _socket = null;
//     }
//
//     try {
//       developer.log('Connecting to socket: $serverUrl', name: 'SOCKET_SERVICE');
//
//       _socket = IO.io(
//         serverUrl,
//         IO.OptionBuilder()
//             .setTransports(['websocket', 'polling'])
//             .enableAutoConnect()
//             .enableReconnection()
//             .setReconnectionDelay(1000)
//             .setReconnectionDelayMax(5000)
//             .setReconnectionAttempts(5)
//             .build(),
//       );
//
//       // Setup core connection handlers
//       _setupCoreEventHandlers(
//         hotelOwnerId: hotelOwnerId,
//         role: role,
//         userId: userId,
//         employeeName: employeeName,
//       );
//
//       developer.log('⏳ Socket initialized, waiting for connection...', name: 'SOCKET_SERVICE');
//     } catch (e) {
//       developer.log('❌ Socket connection error: $e', name: 'SOCKET_SERVICE');
//       _isConnected = false;
//       rethrow;
//     }
//   }
//
//   /// Setup ONLY core connection event handlers
//   /// Business logic events should be registered by controllers
//   void _setupCoreEventHandlers({
//     required int hotelOwnerId,
//     required String role,
//     required int userId,
//     required String employeeName,
//   }) {
//     // Connection lifecycle events
//     _socket!.onConnect((_) {
//       _isConnected = true;
//       developer.log('✅ Socket connected successfully', name: 'SOCKET_SERVICE');
//
//       // Auto-join hotel room on connection
//       _socket!.emit('join', {
//         'hotelOwnerId': hotelOwnerId,
//         'role': role,
//         'id': userId,
//         'employeeName': employeeName,
//       });
//
//       developer.log(
//         '📤 Emitted join event - User: $employeeName, Role: $role, HotelID: $hotelOwnerId',
//         name: 'SOCKET_SERVICE',
//       );
//     });
//
//     _socket!.onDisconnect((_) {
//       _isConnected = false;
//       developer.log('🔌 Socket disconnected', name: 'SOCKET_SERVICE');
//     });
//
//     _socket!.onConnectError((error) {
//       _isConnected = false;
//       developer.log('❌ Connection error: $error', name: 'SOCKET_SERVICE');
//     });
//
//     _socket!.onError((error) {
//       developer.log('❌ Socket error: $error', name: 'SOCKET_SERVICE');
//     });
//
//     // Reconnection events
//     _socket!.on('reconnect_attempt', (attempt) {
//       developer.log('🔄 Reconnection attempt: $attempt', name: 'SOCKET_SERVICE');
//     });
//
//     _socket!.on('reconnect', (attempt) {
//       _isConnected = true;
//       developer.log('✅ Reconnected after $attempt attempts', name: 'SOCKET_SERVICE');
//     });
//
//     _socket!.on('reconnect_failed', (_) {
//       _isConnected = false;
//       developer.log('❌ Reconnection failed', name: 'SOCKET_SERVICE');
//     });
//
//     // Authentication events
//     _socket!.on('authenticated', (data) {
//       developer.log('✅ Authenticated: $data', name: 'SOCKET_SERVICE');
//       _notifyListeners('authenticated', data);
//     });
//
//     _socket!.on('authentication_error', (data) {
//       developer.log('❌ Auth error: $data', name: 'SOCKET_SERVICE');
//       _notifyListeners('authentication_error', data);
//     });
//
//     _socket!.on('join_success', (data) {
//       developer.log('✅ Successfully joined room: $data', name: 'SOCKET_SERVICE');
//       _notifyListeners('join_success', data);
//     });
//   }
//
//   /// ✅ FIXED: Register event listener properly
//   void on(String event, Function callback) {
//     // Check if this event is new (first registration)
//     final isNewEvent = !_eventListeners.containsKey(event);
//
//     // Initialize listener list if new
//     if (isNewEvent) {
//       _eventListeners[event] = [];
//     }
//
//     // Add callback to listeners
//     _eventListeners[event]!.add(callback);
//
//     // ✅ Register with socket ONLY if this is a NEW event
//     if (isNewEvent && _socket != null) {
//       _socket!.on(event, (data) {
//         developer.log('📨 Event received: $event', name: 'SOCKET_SERVICE');
//         _notifyListeners(event, data);
//       });
//       developer.log(
//         '✅ Socket listener registered: $event',
//         name: 'SOCKET_SERVICE',
//       );
//     } else {
//       developer.log(
//         '✅ Added callback to existing listener: $event (Total: ${_eventListeners[event]!.length})',
//         name: 'SOCKET_SERVICE',
//       );
//     }
//   }
//
//   /// Unregister event listener
//   void off(String event, [Function? callback]) {
//     if (callback == null) {
//       // Remove all listeners for this event
//       _eventListeners.remove(event);
//       if (_socket != null) {
//         _socket!.off(event);
//       }
//       developer.log(
//         'Removed all listeners for event: $event',
//         name: 'SOCKET_SERVICE',
//       );
//     } else {
//       // Remove specific callback
//       _eventListeners[event]?.remove(callback);
//       if (_eventListeners[event]?.isEmpty ?? false) {
//         _eventListeners.remove(event);
//         if (_socket != null) {
//           _socket!.off(event);
//         }
//       }
//       developer.log(
//         'Removed specific listener for event: $event',
//         name: 'SOCKET_SERVICE',
//       );
//     }
//   }
//
//   /// Notify all listeners for an event
//   void _notifyListeners(String event, dynamic data) {
//     if (_eventListeners.containsKey(event)) {
//       // Create a copy to avoid concurrent modification
//       final listeners = List.from(_eventListeners[event]!);
//       for (var callback in listeners) {
//         try {
//           callback(data);
//         } catch (e, stackTrace) {
//           developer.log(
//             '❌ Error in listener callback for $event: $e\n$stackTrace',
//             name: 'SOCKET_SERVICE',
//           );
//         }
//       }
//     }
//   }
//
//   /// Emit event to server
//   void emit(String event, dynamic data) {
//     if (_socket != null && _isConnected) {
//       _socket!.emit(event, data);
//       developer.log(
//         '📤 Emitted event: $event',
//         name: 'SOCKET_SERVICE',
//       );
//     } else {
//       developer.log(
//         '⚠️ Cannot emit "$event" - socket not connected',
//         name: 'SOCKET_SERVICE',
//       );
//     }
//   }
//
//   /// Disconnect socket
//   void disconnect() {
//     if (_socket != null) {
//       developer.log('Disconnecting socket', name: 'SOCKET_SERVICE');
//       _socket!.disconnect();
//       _socket!.dispose();
//       _socket = null;
//       _isConnected = false;
//       _eventListeners.clear();
//       developer.log('✅ Socket disconnected and disposed', name: 'SOCKET_SERVICE');
//     }
//   }
//
//   /// Reconnect socket
//   void reconnect() {
//     if (_socket != null && !_isConnected) {
//       developer.log('Reconnecting socket', name: 'SOCKET_SERVICE');
//       _socket!.connect();
//     } else if (_socket == null) {
//       developer.log(
//         '⚠️ Cannot reconnect - socket is null. Use connect() instead.',
//         name: 'SOCKET_SERVICE',
//       );
//     }
//   }
//
//   /// Get connection information
//   Map<String, dynamic> getConnectionInfo() {
//     return {
//       'isConnected': _isConnected,
//       'socketExists': _socket != null,
//       'activeListeners': _eventListeners.length,
//       'registeredEvents': _eventListeners.keys.toList(),
//     };
//   }
// }


import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;

  // ✅ Track which events are registered with the actual socket
  final Map<String, List<Function>> _eventListeners = {};
  final Set<String> _registeredSocketEvents = {};

  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initialize and connect to socket server
  Future<void> connect({
    required String serverUrl,
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
    String? authToken,
  }) async {
    if (_socket != null && _isConnected) {
      developer.log('Socket already connected', name: 'SOCKET_SERVICE');
      return;
    }

    // Dispose existing socket if present
    if (_socket != null) {
      developer.log('Disposing existing socket instance', name: 'SOCKET_SERVICE');
      _socket!.dispose();
      _socket = null;
      _registeredSocketEvents.clear();
    }

    try {
      developer.log('Connecting to socket: $serverUrl', name: 'SOCKET_SERVICE');

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // Setup core connection handlers
      _setupCoreEventHandlers(
        hotelOwnerId: hotelOwnerId,
        role: role,
        userId: userId,
        employeeName: employeeName,
      );

      // ✅ CRITICAL FIX: Re-register all pending event listeners with the new socket
      _reregisterPendingListeners();

      developer.log('⏳ Socket initialized, waiting for connection...', name: 'SOCKET_SERVICE');
    } catch (e) {
      developer.log('❌ Socket connection error: $e', name: 'SOCKET_SERVICE');
      _isConnected = false;
      rethrow;
    }
  }

  /// Setup ONLY core connection event handlers
  void _setupCoreEventHandlers({
    required int hotelOwnerId,
    required String role,
    required int userId,
    required String employeeName,
  }) {
    // Connection lifecycle events
    _socket!.onConnect((_) {
      _isConnected = true;
      developer.log('✅ Socket connected successfully', name: 'SOCKET_SERVICE');

      // ✅ CRITICAL: Re-register all listeners after reconnection
      _reregisterPendingListeners();

      // Auto-join hotel room on connection
      _socket!.emit('join', {
        'hotelOwnerId': hotelOwnerId,
        'role': role,
        'id': userId,
        'employeeName': employeeName,
      });

      developer.log(
        '📤 Emitted join event - User: $employeeName, Role: $role, HotelID: $hotelOwnerId',
        name: 'SOCKET_SERVICE',
      );
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _registeredSocketEvents.clear(); // ✅ Clear on disconnect
      developer.log('🔌 Socket disconnected', name: 'SOCKET_SERVICE');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      developer.log('❌ Connection error: $error', name: 'SOCKET_SERVICE');
    });

    _socket!.onError((error) {
      developer.log('❌ Socket error: $error', name: 'SOCKET_SERVICE');
    });

    // Reconnection events
    _socket!.on('reconnect_attempt', (attempt) {
      developer.log('🔄 Reconnection attempt: $attempt', name: 'SOCKET_SERVICE');
    });

    _socket!.on('reconnect', (attempt) {
      _isConnected = true;
      developer.log('✅ Reconnected after $attempt attempts', name: 'SOCKET_SERVICE');
      _reregisterPendingListeners(); // ✅ Re-register after reconnect
    });

    _socket!.on('reconnect_failed', (_) {
      _isConnected = false;
      developer.log('❌ Reconnection failed', name: 'SOCKET_SERVICE');
    });

    // Authentication events
    _socket!.on('authenticated', (data) {
      developer.log('✅ Authenticated: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('authenticated', data);
    });

    _socket!.on('authentication_error', (data) {
      developer.log('❌ Auth error: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('authentication_error', data);
    });

    _socket!.on('join_success', (data) {
      developer.log('✅ Successfully joined room: $data', name: 'SOCKET_SERVICE');
      _notifyListeners('join_success', data);
    });
  }

  /// ✅ CRITICAL FIX: Re-register all pending listeners with the socket
  void _reregisterPendingListeners() {
    if (_socket == null) return;

    developer.log(
      '🔄 Re-registering ${_eventListeners.length} pending event listeners',
      name: 'SOCKET_SERVICE',
    );

    for (var event in _eventListeners.keys) {
      _registerSocketListener(event);
    }

    developer.log(
      '✅ Re-registered ${_registeredSocketEvents.length} socket listeners',
      name: 'SOCKET_SERVICE',
    );
  }

  /// ✅ FIXED: Register event listener with proper socket registration
  void on(String event, Function callback) {
    // Initialize listener list if new
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }

    // Add callback to listeners
    _eventListeners[event]!.add(callback);

    // ✅ Register with socket if not already registered
    _registerSocketListener(event);

    developer.log(
      '✅ Added listener for "$event" (Total callbacks: ${_eventListeners[event]!.length})',
      name: 'SOCKET_SERVICE',
    );
  }

  /// ✅ NEW: Separate method to register socket listener
  void _registerSocketListener(String event) {
    if (_socket == null || _registeredSocketEvents.contains(event)) {
      return; // Already registered or socket not ready
    }

    _socket!.on(event, (data) {
      developer.log('📨 Event received: $event', name: 'SOCKET_SERVICE');
      _notifyListeners(event, data);
    });

    _registeredSocketEvents.add(event);

    developer.log(
      '✅ Socket listener registered: $event',
      name: 'SOCKET_SERVICE',
    );
  }

  /// Unregister event listener
  void off(String event, [Function? callback]) {
    if (callback == null) {
      // Remove all listeners for this event
      _eventListeners.remove(event);
      _registeredSocketEvents.remove(event);
      if (_socket != null) {
        _socket!.off(event);
      }
      developer.log(
        'Removed all listeners for event: $event',
        name: 'SOCKET_SERVICE',
      );
    } else {
      // Remove specific callback
      _eventListeners[event]?.remove(callback);
      if (_eventListeners[event]?.isEmpty ?? false) {
        _eventListeners.remove(event);
        _registeredSocketEvents.remove(event);
        if (_socket != null) {
          _socket!.off(event);
        }
      }
      developer.log(
        'Removed specific listener for event: $event',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_eventListeners.containsKey(event)) {
      // Create a copy to avoid concurrent modification
      final listeners = List.from(_eventListeners[event]!);

      developer.log(
        '📢 Notifying ${listeners.length} listeners for event: $event',
        name: 'SOCKET_SERVICE',
      );

      for (var callback in listeners) {
        try {
          callback(data);
        } catch (e, stackTrace) {
          developer.log(
            '❌ Error in listener callback for $event: $e\n$stackTrace',
            name: 'SOCKET_SERVICE',
          );
        }
      }
    } else {
      developer.log(
        '⚠️ No listeners registered for event: $event',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Emit event to server
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      developer.log(
        '📤 Emitted event: $event',
        name: 'SOCKET_SERVICE',
      );
    } else {
      developer.log(
        '⚠️ Cannot emit "$event" - socket not connected (isConnected: $_isConnected, socket: ${_socket != null})',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      developer.log('Disconnecting socket', name: 'SOCKET_SERVICE');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _registeredSocketEvents.clear();
      // ✅ Keep _eventListeners to re-register on reconnect
      developer.log('✅ Socket disconnected and disposed', name: 'SOCKET_SERVICE');
    }
  }

  /// Reconnect socket
  void reconnect() {
    if (_socket != null && !_isConnected) {
      developer.log('Reconnecting socket', name: 'SOCKET_SERVICE');
      _socket!.connect();
    } else if (_socket == null) {
      developer.log(
        '⚠️ Cannot reconnect - socket is null. Use connect() instead.',
        name: 'SOCKET_SERVICE',
      );
    }
  }

  /// Get connection information
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'socketExists': _socket != null,
      'activeListeners': _eventListeners.length,
      'registeredSocketEvents': _registeredSocketEvents.length,
      'registeredEvents': _eventListeners.keys.toList(),
      'socketEventsList': _registeredSocketEvents.toList(),
    };
  }

  /// ✅ NEW: Force re-registration of all listeners (for debugging)
  void forceReregisterListeners() {
    developer.log(
      '🔧 Force re-registering all listeners',
      name: 'SOCKET_SERVICE',
    );
    _registeredSocketEvents.clear();
    _reregisterPendingListeners();
  }
}