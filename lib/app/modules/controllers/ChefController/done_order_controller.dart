
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/ResponseModel/pending_orders_model.dart';
import '../../../data/repositories/preparing_orders_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../service/socket_connection_manager.dart';

class DoneOrderController extends GetxController {

  final PreparingOrdersRepository _repository;

  DoneOrderController({PreparingOrdersRepository? repository})
      : _repository = repository ?? PreparingOrdersRepository();

  // Reactive state variables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final ordersData = <GroupedOrder>[].obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;
  final isRejectDialogVisible = false.obs;
  final selectedOrderId = Rxn<int>();
  final expandedOrders = <int>{}.obs;
  final isSocketConnected = false.obs;

  final TextEditingController reasonController = TextEditingController();

  // Socket & debounce
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
  Timer? _refreshDebounceTimer;
  final _refreshDebounceDelay = const Duration(milliseconds: 500);
  bool _isRefreshing = false;
  final Set<String> _processedEvents = {};

  // Notification service
  final NotificationService _notificationService = NotificationService.instance;

  @override
  void onInit() {
    super.onInit();
    developer.log('DoneOrderController initialized', name: 'DoneOrders');

    // Setup socket listeners (removed debug listener)
    _setupSocketListeners();
    isSocketConnected.value = _socketManager.connectionStatus;

    fetchPendingOrders();
  }

  @override
  void onClose() {
    _refreshDebounceTimer?.cancel();
    _removeSocketListeners();
    reasonController.dispose();
    developer.log('DoneOrderController disposed', name: 'DoneOrders');
    super.onClose();
  }

  /// ==================== SOCKET SETUP ====================

  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'DoneOrders.Socket');
    _removeSocketListeners();

    // Register event handlers for preparing/done orders ONLY
    final events = {
      'order_preparing': _handleOrderPreparing,
      'item_preparing': _handleOrderPreparing,
      'order_ready': _handleOrderReady,
      'item_ready': _handleOrderReady,
      'order_status_update': _handleOrderStatusUpdate,
      'item_status_update': _handleItemStatusUpdate,
      'order_completed': _handleOrderCompleted,
      'order_cancelled': _handleOrderCancelled,
      // 'chef_panel_update': _handleItemStatusUpdate,
      // ❌ REMOVED 'new_order' - handled by AcceptOrderController
      // ❌ REMOVED 'placeOrder_ack' - handled by AcceptOrderController
    };

    events.forEach((eventName, handler) {
      _socketManager.socketService.on(eventName, (dynamic data) {
        developer.log('🎯 Event "$eventName" triggered, calling handler...',
            name: 'DoneOrders.Socket');
        try {
          handler(data);
          developer.log('✅ Handler completed for: $eventName',
              name: 'DoneOrders.Socket');
        } catch (e, stackTrace) {
          developer.log('❌ Handler error for $eventName: $e\n$stackTrace',
              name: 'DoneOrders.Socket.Error');
        }
      });
      developer.log('✓ Registered: $eventName', name: 'DoneOrders.Socket');
    });

    ever(_socketManager.isConnected, _onSocketConnectionChanged);

    developer.log('✅ ${events.length} socket listeners registered',
        name: 'DoneOrders.Socket');
  }

  void _removeSocketListeners() {
    final events = [
      'order_preparing',
      'item_preparing',
      'order_ready',
      'item_ready',
      'order_status_update',
      'item_status_update',
      'order_completed',
      'order_cancelled',
      'chef_panel_update',
      // ❌ REMOVED 'new_order'
      // ❌ REMOVED 'placeOrder_ack'
    ];
    events.forEach(_socketManager.socketService.off);
    developer.log('✅ Socket listeners removed', name: 'DoneOrders.Socket');
  }

  void _onSocketConnectionChanged(bool connected) {
    isSocketConnected.value = connected;
    developer.log('Socket connection: $connected', name: 'DoneOrders.Socket');
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  void _handleOrderPreparing(dynamic rawData) {
    developer.log('👨‍🍳 ORDER PREPARING HANDLER CALLED', name: 'DoneOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) {
      developer.log('❌ Failed to parse socket data', name: 'DoneOrders.Socket');
      return;
    }

    developer.log('✅ Data parsed successfully', name: 'DoneOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);
    final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    final eventId = 'preparing-$orderId-$timestamp';

    developer.log(
        '📊 Extracted data: orderId=$orderId, table=$tableNumber',
        name: 'DoneOrders.Socket'
    );

    if (_isDuplicateEvent(eventId)) {
      developer.log('⏭️ Duplicate event detected: $eventId', name: 'DoneOrders.Socket');
      return;
    }

    developer.log(
        '📋 Order #$orderId is now preparing - Table $tableNumber',
        name: 'DoneOrders.Socket'
    );

    developer.log('🔄 Calling debounced refresh...', name: 'DoneOrders.Socket');
    _debouncedRefreshOrders();

    developer.log('✅ Handler completed', name: 'DoneOrders.Socket');
  }

  void _handleOrderReady(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('✅ ORDER READY EVENT', name: 'DoneOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);
    final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    final eventId = 'ready-$orderId-$timestamp';

    if (_isDuplicateEvent(eventId)) return;

    developer.log('📋 Order #$orderId is ready - Table $tableNumber',
        name: 'DoneOrders.Socket');

    _debouncedRefreshOrders();

    // Remove order from preparing list as it's now ready
    if (orderId > 0) {
      _removeOrderFromList(orderId);
    }
  }

  void _handleOrderStatusUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 ORDER STATUS UPDATE EVENT', name: 'DoneOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final status = orderData['status'] ?? orderData['order_status'];
    final tableNumber = _extractTableNumber(orderData);

    developer.log('Status received: $status for order #$orderId',
        name: 'DoneOrders.Socket');

    // Handle different status transitions
    if (status == 'preparing') {
      _debouncedRefreshOrders();
    } else if (status == 'ready' || status == 'ready_to_serve') {
      _debouncedRefreshOrders();
      if (orderId > 0) {
        _removeOrderFromList(orderId);
      }
    } else if (status == 'completed' || status == 'served') {
      _debouncedRefreshOrders();
      if (orderId > 0) {
        _removeOrderFromList(orderId);
      }
    }
  }

  void _handleItemStatusUpdate(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 ITEM STATUS UPDATE EVENT', name: 'DoneOrders.Socket');

    final itemData = data['data'] ?? data;
    final status = itemData['item_status'] ?? itemData['status'];
    final orderId = _extractOrderId(itemData);

    developer.log('Item status: $status for order #$orderId',
        name: 'DoneOrders.Socket');

    // Refresh if items are transitioning to ready or completed
    if (status == 'ready' || status == 'completed') {
      _debouncedRefreshOrders();
    }
    fetchPendingOrders();
    developer.log('Fetched pending orders after item status update', name: 'vaibhav.Socket');
  }

  void _handleOrderCompleted(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('🎉 ORDER COMPLETED EVENT', name: 'DoneOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);

    _debouncedRefreshOrders();

    if (orderId > 0) {
      _removeOrderFromList(orderId);
    }
  }

  void _handleOrderCancelled(dynamic rawData) {
    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('❌ ORDER CANCELLED EVENT', name: 'DoneOrders.Socket');

    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final tableNumber = _extractTableNumber(orderData);

    _debouncedRefreshOrders();

    if (orderId > 0) {
      _removeOrderFromList(orderId);
    }
  }

  /// ==================== HELPER METHODS ====================

  Map<String, dynamic>? _parseSocketData(dynamic rawData) {
    try {
      return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    } catch (e) {
      developer.log('❌ Parse error: $e', name: 'DoneOrders.Socket.Error');
      return null;
    }
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      developer.log('⏭️ SKIPPING duplicate: $eventId',
          name: 'DoneOrders.Socket');
      return true;
    }
    _processedEvents.add(eventId);
    if (_processedEvents.length > 50) _processedEvents.clear();
    return false;
  }

  int _extractOrderId(Map<String, dynamic>? data) {
    return data?['id'] ?? data?['order_id'] ?? data?['orderId'] ?? 0;
  }

  String _extractTableNumber(Map<String, dynamic>? data) {
    return data?['table_number']?.toString() ??
        data?['tableNumber']?.toString() ??
        'Unknown';
  }

  void _removeOrderFromList(int orderId) {
    try {
      ordersData.removeWhere((order) => order.orderId == orderId);
      developer.log('✅ Order #$orderId removed from list',
          name: 'DoneOrders.Socket');
    } catch (e, stackTrace) {
      developer.log('❌ Remove error: $e\n$stackTrace',
          name: 'DoneOrders.Socket.Error');
    }
  }

  void _debouncedRefreshOrders() {
    developer.log('🔄 Debouncing refresh... (timer will fire in ${_refreshDebounceDelay.inMilliseconds}ms)',
        name: 'DoneOrders.Socket');
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      developer.log('⏰ Debounce timer fired!', name: 'DoneOrders.Socket');
      if (!_isRefreshing) {
        developer.log('⏰ Executing debounced refresh - calling fetchPendingOrders()',
            name: 'DoneOrders.Socket');
        fetchPendingOrders(isRefresh: true);
      } else {
        developer.log('⏭️ Skipping refresh - already in progress',
            name: 'DoneOrders.Socket');
      }
    });
  }

  /// ==================== API METHODS ====================

  /// Fetch pending orders from API
  Future<void> fetchPendingOrders({bool isRefresh = false}) async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing - skipping', name: 'DoneOrders');
      return;
    }

    try {
      _isRefreshing = true;
      developer.log('🚀 Starting fetch - isRefresh=$isRefresh', name: 'DoneOrders');

      if (isRefresh) {
        isRefreshing.value = true;
        developer.log('📊 Set isRefreshing observable to true', name: 'DoneOrders');
      } else {
        isLoading.value = true;
        developer.log('📊 Set isLoading observable to true', name: 'DoneOrders');
      }
      errorMessage.value = '';

      developer.log('📡 Calling repository.getPendingOrders()', name: 'DoneOrders');
      final groupedOrders = await _repository.getPendingOrders();

      developer.log('📥 Got ${groupedOrders.length} orders from API', name: 'DoneOrders');
      ordersData.value = groupedOrders;

      // Force UI update
      ordersData.refresh();
      developer.log('✅ ${ordersData.length} orders loaded', name: 'DoneOrders');
    } catch (e) {
      errorMessage.value = e.toString();
      developer.log('❌ Fetch error: $e', name: 'DoneOrders.Error');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      _isRefreshing = false;
      developer.log('✅ Fetch completed - reset flags', name: 'DoneOrders');
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    developer.log('♻️ Manual refresh', name: 'DoneOrders');
    await fetchPendingOrders(isRefresh: true);
  }

  /// Toggle order expansion
  void toggleOrderExpansion(int orderId) {
    if (expandedOrders.contains(orderId)) {
      expandedOrders.remove(orderId);
    } else {
      expandedOrders.add(orderId);
    }
  }

  /// Accept order
  Future<void> acceptOrder(BuildContext context, int orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final orderIndex = ordersData.indexWhere((order) => order.orderId == orderId);
      if (orderIndex == -1) return;

      final order = ordersData[orderIndex];

      // Update status for all items in the order
      await _repository.updateAllOrderItemsStatus(
        orderId: order.orderId,
        itemIds: order.items.map((item) => item.id).toList(),
        status: 'ready',
      );

      SnackBarUtil.showSuccess(
        context,
        'Order #${order.orderId} has been completed successfully',
        title: 'Order Accepted',
        duration: const Duration(seconds: 2),
      );

      // Remove the accepted order from the list
      Future.delayed(const Duration(milliseconds: 500), () {
        ordersData.removeAt(orderIndex);
      });
    } catch (e) {
      errorMessage.value = e.toString();
      SnackBarUtil.showError(
        context,
        'Failed to accept order: ${e.toString()}',
        title: 'Accept Failed',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Show rejection dialog
  void showRejectDialog(int orderId) {
    selectedOrderId.value = orderId;
    isRejectDialogVisible.value = true;
    reasonController.clear();
    rejectionReason.value = '';
  }

  /// Hide rejection dialog
  void hideRejectDialog() {
    isRejectDialogVisible.value = false;
    selectedOrderId.value = null;
    reasonController.clear();
    rejectionReason.value = '';
  }

  /// Update rejection reason
  void updateRejectionReason(String reason) {
    rejectionReason.value = reason;
  }

  /// Format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Validate rejection reason
  String? validateRejectionReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a reason for cancellation';
    }
    if (value.trim().length < 10) {
      return 'Reason must be at least 10 characters long';
    }
    if (value.trim().length > 500) {
      return 'Reason cannot exceed 500 characters';
    }
    return null;
  }

  // Getters
  bool get socketConnected => isSocketConnected.value;
  int get totalOrders => ordersData.length;
  Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
}




// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import 'dart:async';
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/models/ResponseModel/pending_orders_model.dart';
// import '../../../data/repositories/preparing_orders_repository.dart';
// import '../../../core/services/notification_service.dart';
// import '../../service/socket_connection_manager.dart';
//
// class DoneOrderController extends GetxController {
//
//   final PreparingOrdersRepository _repository;
//
//   DoneOrderController({PreparingOrdersRepository? repository})
//       : _repository = repository ?? PreparingOrdersRepository();
//
//   // Reactive state variables
//   final isLoading = false.obs;
//   final isRefreshing = false.obs;
//   final ordersData = <GroupedOrder>[].obs;
//   final errorMessage = ''.obs;
//   final rejectionReason = ''.obs;
//   final isRejectDialogVisible = false.obs;
//   final selectedOrderId = Rxn<int>();
//   final expandedOrders = <int>{}.obs;
//   final isSocketConnected = false.obs;
//
//   final TextEditingController reasonController = TextEditingController();
//
//   // Socket & debounce
//   final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
//   Timer? _refreshDebounceTimer;
//   final _refreshDebounceDelay = const Duration(milliseconds: 500);
//   bool _isRefreshing = false;
//   final Set<String> _processedEvents = {};
//
//   // Notification service
//   final NotificationService _notificationService = NotificationService.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('DoneOrderController initialized', name: 'DoneOrders');
//
//     // Setup socket listeners (removed debug listener)
//     _setupSocketListeners();
//     isSocketConnected.value = _socketManager.connectionStatus;
//
//     fetchPendingOrders();
//   }
//
//   @override
//   void onClose() {
//     _refreshDebounceTimer?.cancel();
//     _removeSocketListeners();
//     reasonController.dispose();
//     developer.log('DoneOrderController disposed', name: 'DoneOrders');
//     super.onClose();
//   }
//
//   /// ==================== SOCKET SETUP ====================
//   void _setupSocketListeners() {
//     developer.log('🔌 Setting up socket listeners', name: 'DoneOrders.Socket');
//     _removeSocketListeners();
//
//     final events = {
//       // ✅ Status transition events - matching backend event names
//       'order_preparing': _handleOrderPreparing,
//       'item_preparing': _handleOrderPreparing,
//       'item_status_preparing': _handleOrderPreparing,
//
//       'order_ready': _handleOrderReady,
//       'item_ready': _handleOrderReady,
//       'item_status_ready': _handleOrderReady,
//       'item_ready_for_service': _handleOrderReady,
//
//       // ✅ CRITICAL: Generic item status updates
//       'order_status_update': _handleOrderStatusUpdate,
//       'item_status_update': _handleItemStatusUpdate,
//
//       // ✅ Completion/cancellation
//       'order_completed': _handleOrderCompleted,
//       'order_cancelled': _handleOrderCancelled,
//       'order_cancelled_alert': _handleOrderCancelled,
//
//       // ✅ NEW: Sync events from other chefs/waiters
//       'item_rejected': _handleItemRejected,
//       'remove_ready_item': _handleRemoveReadyItem,
//       'order_full_refresh': _handleGenericUpdate,
//     };
//
//     events.forEach((eventName, handler) {
//       _socketManager.socketService.on(eventName, (dynamic data) {
//         developer.log(
//           '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
//           name: 'DoneOrders.Socket',
//         );
//         developer.log(
//           '🎯 [BROADCAST] Event "$eventName" received',
//           name: 'DoneOrders.Socket',
//         );
//
//         // ✅ Enhanced logging
//         if (data is Map) {
//           developer.log(
//             '📦 Payload keys: ${data.keys.toList()}',
//             name: 'DoneOrders.Socket',
//           );
//
//           if (data.containsKey('data') && data['data'] is Map) {
//             final innerData = data['data'] as Map;
//             developer.log(
//               '📋 Inner data keys: ${innerData.keys.toList()}',
//               name: 'DoneOrders.Socket',
//             );
//           }
//         }
//
//         developer.log(
//           '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
//           name: 'DoneOrders.Socket',
//         );
//
//         try {
//           handler!;
//           developer.log(
//             '✅ Handler completed: $eventName',
//             name: 'DoneOrders.Socket',
//           );
//         } catch (e, stackTrace) {
//           developer.log(
//             '❌ Handler error: $e\n$stackTrace',
//             name: 'DoneOrders.Socket.Error',
//           );
//
//           // ✅ Force refresh on error
//           _debouncedRefreshOrders();
//         }
//       });
//     });
//
//     ever(_socketManager.isConnected, _onSocketConnectionChanged);
//
//     developer.log(
//       '✅ ${events.length} socket listeners registered',
//       name: 'DoneOrders.Socket',
//     );
//   }
//
//   void _handleGenericUpdate(dynamic rawData) {
//     developer.log('📊 Generic update event', name: 'AcceptOrders.Socket');
//     _debouncedRefreshOrders();
//   }
//
//
//   void _handleItemStatusUpdate(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('📊 ITEM STATUS UPDATE EVENT', name: 'DoneOrders.Socket');
//
//     try {
//       // ✅ Extract data matching backend format
//       Map<String, dynamic>? itemData;
//
//       if (data.containsKey('data') && data['data'] is Map) {
//         itemData = data['data'] as Map<String, dynamic>;
//       } else if (data.containsKey('itemId') || data.containsKey('item_id')) {
//         itemData = data;
//       }
//
//       if (itemData == null || itemData.isEmpty) {
//         developer.log(
//           '⚠️ No item data - Available keys: ${data.keys.toList()}',
//           name: 'DoneOrders.Socket',
//         );
//         _debouncedRefreshOrders();
//         return;
//       }
//
//       // ✅ Extract values matching backend field names
//       final orderId = itemData['orderId'] ??
//           itemData['order_id'] ??
//           itemData['id'];
//
//       final itemId = itemData['itemId'] ??
//           itemData['item_id'];
//
//       final status = itemData['newStatus'] as String? ??
//           itemData['status'] as String? ??
//           itemData['item_status'] as String? ??
//           itemData['itemStatus'] as String?;
//
//       // Convert to int
//       final orderIdInt = orderId is int ? orderId : int.tryParse(orderId?.toString() ?? '0');
//       final itemIdInt = itemId is int ? itemId : int.tryParse(itemId?.toString() ?? '0');
//
//       developer.log(
//         '✅ Extracted: orderId=$orderIdInt, itemId=$itemIdInt, status=$status',
//         name: 'DoneOrders.Socket',
//       );
//
//       if (orderIdInt == null || orderIdInt == 0) {
//         developer.log('⚠️ Invalid order ID', name: 'DoneOrders.Socket');
//         _debouncedRefreshOrders();
//         return;
//       }
//
//       // ✅ Handle different status transitions
//       if (status == 'preparing') {
//         // Item moved to preparing - should appear in this list
//         developer.log(
//           '➕ Item now preparing - refreshing to add',
//           name: 'DoneOrders.Socket',
//         );
//         _debouncedRefreshOrders();
//       } else if (status == 'ready' || status == 'served' || status == 'completed') {
//         // Item moved beyond preparing - remove from this list
//         developer.log(
//           '➖ Item no longer preparing - removing',
//           name: 'DoneOrders.Socket',
//         );
//
//         if (itemIdInt != null && itemIdInt > 0) {
//           _removeItemFromOrder(orderIdInt, itemIdInt);
//         }
//
//         _debouncedRefreshOrders();
//       } else if (status == 'rejected' || status == 'cancelled') {
//         // Item rejected/cancelled - remove immediately
//         developer.log(
//           '❌ Item rejected/cancelled - removing',
//           name: 'DoneOrders.Socket',
//         );
//
//         if (itemIdInt != null && itemIdInt > 0) {
//           _removeItemFromOrder(orderIdInt, itemIdInt);
//         }
//
//         ordersData.refresh();
//       }
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Error: $e\n$stackTrace',
//         name: 'DoneOrders.Socket.Error',
//       );
//       _debouncedRefreshOrders();
//     }
//   }
//
// // ============================================================================
// // ✅ NEW: Additional Event Handlers
// // ============================================================================
//
//   /// Handle item rejected by chef
//   void _handleItemRejected(dynamic rawData) {
//     developer.log('❌ ITEM REJECTED EVENT', name: 'DoneOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     final itemData = data['data'] ?? data;
//     final orderId = _extractOrderId(itemData);
//     final itemId = _extractItemId(itemData);
//
//     if (orderId > 0 && itemId! > 0) {
//       _removeItemFromOrder(orderId, itemId!);
//       ordersData.refresh();
//
//       developer.log(
//         '✅ Rejected item removed from preparing list',
//         name: 'DoneOrders.Socket',
//       );
//     }
//   }
//
//   int? _extractItemId(Map<String, dynamic>? data) {
//     if (data == null) return null;
//
//     final id = data['itemId'] ??
//         data['item_id'] ??
//         data['id'];
//
//     if (id == null) return null;
//
//     return id is int ? id : int.tryParse(id.toString());
//   }
//
//   /// Handle remove ready item (when waiter serves item)
//   void _handleRemoveReadyItem(dynamic rawData) {
//     developer.log('🗑️ REMOVE READY ITEM EVENT', name: 'DoneOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     final orderId = _extractOrderId(data);
//     final itemId = _extractItemId(data);
//
//     if (orderId > 0 && itemId! > 0) {
//       _removeItemFromOrder(orderId, itemId!);
//       ordersData.refresh();
//     }
//   }
//
//   /// Remove item from order list
//   void _removeItemFromOrder(int orderId, int itemId) {
//     try {
//       final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//
//       if (orderIndex != -1) {
//         final order = ordersData[orderIndex];
//
//         developer.log(
//           '📊 Before removal: Order #$orderId has ${order.items.length} items',
//           name: 'DoneOrders',
//         );
//
//         order.items.removeWhere((item) => item.id == itemId);
//
//         if (order.items.isEmpty) {
//           ordersData.removeAt(orderIndex);
//           expandedOrders.remove(orderId);
//
//           developer.log(
//             '✅ Removed order #$orderId (no preparing items)',
//             name: 'DoneOrders',
//           );
//         } else {
//           ordersData[orderIndex] = order;
//
//           developer.log(
//             '✅ Updated order #$orderId (${order.items.length} items remaining)',
//             name: 'DoneOrders',
//           );
//         }
//
//         // ✅ CRITICAL: Force UI update
//         ordersData.refresh();
//
//         developer.log(
//           '🔄 UI refresh triggered for all chef panels',
//           name: 'DoneOrders',
//         );
//       } else {
//         developer.log(
//           '⚠️ Order #$orderId not found in preparing list',
//           name: 'DoneOrders',
//         );
//       }
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Remove item error: $e\n$stackTrace',
//         name: 'DoneOrders.Error',
//       );
//
//       _debouncedRefreshOrders();
//     }
//   }
//
// // ============================================================================
// // ✅ UPDATE: Remove socket listeners
// // ============================================================================
//
//   void _removeSocketListeners() {
//     final events = [
//       'order_preparing',
//       'item_preparing',
//       'item_status_preparing',
//       'order_ready',
//       'item_ready',
//       'item_status_ready',
//       'item_ready_for_service',
//       'order_status_update',
//       'item_status_update',
//       'order_completed',
//       'order_cancelled',
//       'order_cancelled_alert',
//       'item_rejected',
//       'remove_ready_item',
//       'order_full_refresh',
//     ];
//
//     events.forEach(_socketManager.socketService.off);
//     developer.log('✅ Socket listeners removed', name: 'DoneOrders.Socket');
//   }
//
//   void _onSocketConnectionChanged(bool connected) {
//     isSocketConnected.value = connected;
//     developer.log('Socket connection: $connected', name: 'DoneOrders.Socket');
//   }
//
//   /// ==================== SOCKET EVENT HANDLERS ====================
//
//   void _handleOrderPreparing(dynamic rawData) {
//     developer.log('👨‍🍳 ORDER PREPARING HANDLER CALLED', name: 'DoneOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) {
//       developer.log('❌ Failed to parse socket data', name: 'DoneOrders.Socket');
//       return;
//     }
//
//     developer.log('✅ Data parsed successfully', name: 'DoneOrders.Socket');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//     final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
//     final eventId = 'preparing-$orderId-$timestamp';
//
//     developer.log(
//         '📊 Extracted data: orderId=$orderId, table=$tableNumber',
//         name: 'DoneOrders.Socket'
//     );
//
//     if (_isDuplicateEvent(eventId)) {
//       developer.log('⏭️ Duplicate event detected: $eventId', name: 'DoneOrders.Socket');
//       return;
//     }
//
//     developer.log(
//         '📋 Order #$orderId is now preparing - Table $tableNumber',
//         name: 'DoneOrders.Socket'
//     );
//
//     developer.log('🔄 Calling debounced refresh...', name: 'DoneOrders.Socket');
//     _debouncedRefreshOrders();
//
//     developer.log('✅ Handler completed', name: 'DoneOrders.Socket');
//   }
//
//   void _handleOrderReady(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('✅ ORDER READY EVENT', name: 'DoneOrders.Socket');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//     final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
//     final eventId = 'ready-$orderId-$timestamp';
//
//     if (_isDuplicateEvent(eventId)) return;
//
//     developer.log('📋 Order #$orderId is ready - Table $tableNumber',
//         name: 'DoneOrders.Socket');
//
//     _debouncedRefreshOrders();
//
//     // Remove order from preparing list as it's now ready
//     if (orderId > 0) {
//       _removeOrderFromList(orderId);
//     }
//   }
//
//   void _handleOrderStatusUpdate(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('📊 ORDER STATUS UPDATE EVENT', name: 'DoneOrders.Socket');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final status = orderData['status'] ?? orderData['order_status'];
//     final tableNumber = _extractTableNumber(orderData);
//
//     developer.log('Status received: $status for order #$orderId',
//         name: 'DoneOrders.Socket');
//
//     // Handle different status transitions
//     if (status == 'preparing') {
//       _debouncedRefreshOrders();
//     } else if (status == 'ready' || status == 'ready_to_serve') {
//       _debouncedRefreshOrders();
//       if (orderId > 0) {
//         _removeOrderFromList(orderId);
//       }
//     } else if (status == 'completed' || status == 'served') {
//       _debouncedRefreshOrders();
//       if (orderId > 0) {
//         _removeOrderFromList(orderId);
//       }
//     }
//   }
//
//   // void _handleItemStatusUpdate(dynamic rawData) {
//   //   final data = _parseSocketData(rawData);
//   //   if (data == null) return;
//   //
//   //   developer.log('📊 ITEM STATUS UPDATE EVENT', name: 'DoneOrders.Socket');
//   //
//   //   final itemData = data['data'] ?? data;
//   //   final status = itemData['item_status'] ?? itemData['status'];
//   //   final orderId = _extractOrderId(itemData);
//   //
//   //   developer.log('Item status: $status for order #$orderId',
//   //       name: 'DoneOrders.Socket');
//   //
//   //   // Refresh if items are transitioning to ready or completed
//   //   if (status == 'ready' || status == 'completed') {
//   //     _debouncedRefreshOrders();
//   //   }
//   // }
//
//   void _handleOrderCompleted(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('🎉 ORDER COMPLETED EVENT', name: 'DoneOrders.Socket');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//
//     _debouncedRefreshOrders();
//
//     if (orderId > 0) {
//       _removeOrderFromList(orderId);
//     }
//   }
//
//   void _handleOrderCancelled(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('❌ ORDER CANCELLED EVENT', name: 'DoneOrders.Socket');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//
//     _debouncedRefreshOrders();
//
//     if (orderId > 0) {
//       _removeOrderFromList(orderId);
//     }
//   }
//
//   /// ==================== HELPER METHODS ====================
//
//   Map<String, dynamic>? _parseSocketData(dynamic rawData) {
//     try {
//       return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
//     } catch (e) {
//       developer.log('❌ Parse error: $e', name: 'DoneOrders.Socket.Error');
//       return null;
//     }
//   }
//
//   bool _isDuplicateEvent(String eventId) {
//     if (_processedEvents.contains(eventId)) {
//       developer.log('⏭️ SKIPPING duplicate: $eventId',
//           name: 'DoneOrders.Socket');
//       return true;
//     }
//     _processedEvents.add(eventId);
//     if (_processedEvents.length > 50) _processedEvents.clear();
//     return false;
//   }
//
//   int _extractOrderId(Map<String, dynamic>? data) {
//     return data?['id'] ?? data?['order_id'] ?? data?['orderId'] ?? 0;
//   }
//
//   String _extractTableNumber(Map<String, dynamic>? data) {
//     return data?['table_number']?.toString() ??
//         data?['tableNumber']?.toString() ??
//         'Unknown';
//   }
//
//   void _removeOrderFromList(int orderId) {
//     try {
//       ordersData.removeWhere((order) => order.orderId == orderId);
//       developer.log('✅ Order #$orderId removed from list',
//           name: 'DoneOrders.Socket');
//     } catch (e, stackTrace) {
//       developer.log('❌ Remove error: $e\n$stackTrace',
//           name: 'DoneOrders.Socket.Error');
//     }
//   }
//
//   void _debouncedRefreshOrders() {
//     developer.log('🔄 Debouncing refresh... (timer will fire in ${_refreshDebounceDelay.inMilliseconds}ms)',
//         name: 'DoneOrders.Socket');
//     _refreshDebounceTimer?.cancel();
//     _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
//       developer.log('⏰ Debounce timer fired!', name: 'DoneOrders.Socket');
//       if (!_isRefreshing) {
//         developer.log('⏰ Executing debounced refresh - calling fetchPendingOrders()',
//             name: 'DoneOrders.Socket');
//         fetchPendingOrders(isRefresh: true);
//       } else {
//         developer.log('⏭️ Skipping refresh - already in progress',
//             name: 'DoneOrders.Socket');
//       }
//     });
//   }
//
//   /// ==================== API METHODS ====================
//
//   /// Fetch pending orders from API
//   Future<void> fetchPendingOrders({bool isRefresh = false}) async {
//     if (_isRefreshing) {
//       developer.log('⏭️ Already refreshing - skipping', name: 'DoneOrders');
//       return;
//     }
//
//     try {
//       _isRefreshing = true;
//       developer.log('🚀 Starting fetch - isRefresh=$isRefresh', name: 'DoneOrders');
//
//       if (isRefresh) {
//         isRefreshing.value = true;
//         developer.log('📊 Set isRefreshing observable to true', name: 'DoneOrders');
//       } else {
//         isLoading.value = true;
//         developer.log('📊 Set isLoading observable to true', name: 'DoneOrders');
//       }
//       errorMessage.value = '';
//
//       developer.log('📡 Calling repository.getPendingOrders()', name: 'DoneOrders');
//       final groupedOrders = await _repository.getPendingOrders();
//
//       developer.log('📥 Got ${groupedOrders.length} orders from API', name: 'DoneOrders');
//       ordersData.value = groupedOrders;
//
//       // Force UI update
//       ordersData.refresh();
//       developer.log('✅ ${ordersData.length} orders loaded', name: 'DoneOrders');
//     } catch (e) {
//       errorMessage.value = e.toString();
//       developer.log('❌ Fetch error: $e', name: 'DoneOrders.Error');
//     } finally {
//       isLoading.value = false;
//       isRefreshing.value = false;
//       _isRefreshing = false;
//       developer.log('✅ Fetch completed - reset flags', name: 'DoneOrders');
//     }
//   }
//
//   /// Refresh orders
//   Future<void> refreshOrders() async {
//     developer.log('♻️ Manual refresh', name: 'DoneOrders');
//     await fetchPendingOrders(isRefresh: true);
//   }
//
//   /// Toggle order expansion
//   void toggleOrderExpansion(int orderId) {
//     if (expandedOrders.contains(orderId)) {
//       expandedOrders.remove(orderId);
//     } else {
//       expandedOrders.add(orderId);
//     }
//   }
//
//   /// Accept order
//   Future<void> acceptOrder(BuildContext context, int orderId) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final orderIndex = ordersData.indexWhere((order) => order.orderId == orderId);
//       if (orderIndex == -1) return;
//
//       final order = ordersData[orderIndex];
//
//       // Update status for all items in the order
//       await _repository.updateAllOrderItemsStatus(
//         orderId: order.orderId,
//         itemIds: order.items.map((item) => item.id).toList(),
//         status: 'ready',
//       );
//
//       SnackBarUtil.showSuccess(
//         context,
//         'Order #${order.orderId} has been completed successfully',
//         title: 'Order Accepted',
//         duration: const Duration(seconds: 2),
//       );
//
//       // Remove the accepted order from the list
//       Future.delayed(const Duration(milliseconds: 500), () {
//         ordersData.removeAt(orderIndex);
//       });
//     } catch (e) {
//       errorMessage.value = e.toString();
//       SnackBarUtil.showError(
//         context,
//         'Failed to accept order: ${e.toString()}',
//         title: 'Accept Failed',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Show rejection dialog
//   void showRejectDialog(int orderId) {
//     selectedOrderId.value = orderId;
//     isRejectDialogVisible.value = true;
//     reasonController.clear();
//     rejectionReason.value = '';
//   }
//
//   /// Hide rejection dialog
//   void hideRejectDialog() {
//     isRejectDialogVisible.value = false;
//     selectedOrderId.value = null;
//     reasonController.clear();
//     rejectionReason.value = '';
//   }
//
//   /// Update rejection reason
//   void updateRejectionReason(String reason) {
//     rejectionReason.value = reason;
//   }
//
//   /// Format currency
//   String formatCurrency(double amount) {
//     return '₹${amount.toStringAsFixed(2)}';
//   }
//
//   /// Validate rejection reason
//   String? validateRejectionReason(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please provide a reason for cancellation';
//     }
//     if (value.trim().length < 10) {
//       return 'Reason must be at least 10 characters long';
//     }
//     if (value.trim().length > 500) {
//       return 'Reason cannot exceed 500 characters';
//     }
//     return null;
//   }
//
//   // Getters
//   bool get socketConnected => isSocketConnected.value;
//   int get totalOrders => ordersData.length;
//   Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
// }
