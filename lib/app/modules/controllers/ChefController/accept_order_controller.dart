//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import 'dart:async';
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/repositories/pending_orders_repository.dart';
// import '../../../data/models/ResponseModel/pending_orders_model.dart';
// import '../../service/socket_connection_manager.dart';
// import '../../../core/services/notification_service.dart';
// import '../../widgets/notifications_widget.dart';
//
// class AcceptOrderController extends GetxController {
//   final PendingOrdersRepository _repository;
//   final notificationService = NotificationService.instance;
//
//   AcceptOrderController({PendingOrdersRepository? repository})
//       : _repository = repository ?? PendingOrdersRepository();
//
//   // Reactive state variables
//   final isLoading = false.obs;
//   final isRefreshing = false.obs;
//   final ordersData = <GroupedOrder>[].obs;
//   final errorMessage = ''.obs;
//   final rejectionReason = ''.obs;
//   final rejectionCategory = 'out_of_stock'.obs;
//   final isRejectDialogVisible = false.obs;
//   final selectedOrderId = Rxn<int>();
//   final selectedItemId = Rxn<int>();
//   final expandedOrders = <int>{}.obs;
//   final processingItems = <int>{}.obs;
//   final isSocketConnected = false.obs;
//
//   final TextEditingController reasonController = TextEditingController();
//
//   // Socket & debounce
//   final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
//
//   Timer? _refreshDebounceTimer;
//   Timer? _retryTimer;
//   final _refreshDebounceDelay = const Duration(milliseconds: 2000); // Increased to 2s for DB commit
//
//   bool _isRefreshing = false;
//   final Set<String> _processedEvents = {};
//   final Set<int> _notifiedOrders = {};
//
//   // Retry logic variables
//   int _retryAttempts = 0;
//   final _maxRetryAttempts = 3;
//
//   // Track if listeners are setup
//   bool _listenersRegistered = false;
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('AcceptOrderController initialized', name: 'AcceptOrders');
//
//     // Setup socket listeners first
//     _setupSocketListeners();
//     isSocketConnected.value = _socketManager.connectionStatus;
//
//     // Monitor socket connection state
//     ever(_socketManager.isConnected, _onSocketConnectionChanged);
//
//     // Fetch orders after socket setup
//     fetchPendingOrders();
//   }
//
//   @override
//   void onClose() {
//     _refreshDebounceTimer?.cancel();
//     _refreshDebounceTimer = null;
//     _retryTimer?.cancel();
//     _retryTimer = null;
//
//     _removeSocketListeners();
//     reasonController.dispose();
//
//     developer.log('AcceptOrderController disposed - all timers cancelled', name: 'AcceptOrders');
//     super.onClose();
//   }
//
//   /// ==================== SOCKET SETUP ====================
//
//   void _setupSocketListeners() {
//     developer.log('🔌 Setting up socket listeners', name: 'AcceptOrders.Socket');
//
//     final socket = _socketManager.socketService.socket;
//     if (socket == null) {
//       developer.log('⚠️ Socket is NULL - scheduling retry', name: 'AcceptOrders.Socket');
//       Future.delayed(Duration(seconds: 1), () {
//         if (_socketManager.socketService.socket != null && !_listenersRegistered) {
//           developer.log('🔄 Socket now available - retrying setup', name: 'AcceptOrders.Socket');
//           _setupSocketListeners();
//         }
//       });
//       return;
//     }
//
//     if (_listenersRegistered) {
//       developer.log('⏭️ Listeners already registered, skipping', name: 'AcceptOrders.Socket');
//       return;
//     }
//
//     _removeSocketListeners();
//
//     // ✅ FIX: Listen to the EXACT events that backend emits
//     final events = {
//       // Primary event from backend for new orders
//       'new_order': _handleNewOrder,
//
//       // Order status updates
//       'order_status_update': _handleOrderStatusUpdate,
//
//       // Item status updates - CRITICAL for chef panel
//       'item_status_update': _handleItemStatusUpdate,
//
//       // New items added to existing order
//       'new_items_added': _handleNewItemsAdded,
//       'new_items_to_prepare': _handleNewItemsAdded, // Alternative event name
//
//       // Test notifications
//       'test_notification': _handleTestNotification,
//
//       // Generic fallbacks (keep for backward compatibility)
//       'order_update': _handleGenericUpdate,
//     };
//
//     events.forEach((eventName, handler) {
//       _socketManager.socketService.on(eventName, (dynamic data) {
//         developer.log(
//           '🎯 [SOCKET EVENT] "$eventName" received',
//           name: 'AcceptOrders.Socket',
//         );
//
//         // Log raw data for debugging
//         developer.log(
//           '📦 Raw data type: ${data.runtimeType}',
//           name: 'AcceptOrders.Socket',
//         );
//
//         try {
//           handler(data);
//           developer.log('✅ Handler completed: $eventName', name: 'AcceptOrders.Socket');
//         } catch (e, stackTrace) {
//           developer.log(
//             '❌ Handler error for $eventName: $e\n$stackTrace',
//             name: 'AcceptOrders.Socket.Error',
//           );
//         }
//       });
//
//       developer.log('✓ Registered listener: $eventName', name: 'AcceptOrders.Socket');
//     });
//
//     _listenersRegistered = true;
//
//     developer.log(
//       '✅ ${events.length} socket listeners registered',
//       name: 'AcceptOrders.Socket',
//     );
//   }
//
//   void _removeSocketListeners() {
//     final events = [
//       'new_order',
//       'order_status_update',
//       'item_status_update',
//       'new_items_added',
//       'new_items_to_prepare',
//       'test_notification',
//       'order_update',
//     ];
//
//     for (var event in events) {
//       _socketManager.socketService.off(event);
//     }
//
//     _listenersRegistered = false;
//     developer.log('✅ Socket listeners removed', name: 'AcceptOrders.Socket');
//   }
//
//   void _onSocketConnectionChanged(bool connected) {
//     isSocketConnected.value = connected;
//     developer.log('Socket connection changed: $connected', name: 'AcceptOrders.Socket');
//
//     if (connected) {
//       developer.log('🔄 Socket reconnected - re-registering listeners', name: 'AcceptOrders.Socket');
//       _listenersRegistered = false;
//       _setupSocketListeners();
//       _debouncedRefreshOrders();
//     }
//   }
//
//   /// ==================== SOCKET EVENT HANDLERS ====================
//
//   void _handleNewOrder(dynamic rawData) {
//     developer.log('🔔 NEW ORDER EVENT RECEIVED', name: 'AcceptOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) {
//       developer.log('❌ Failed to parse socket data', name: 'AcceptOrders.Socket');
//       return;
//     }
//
//     try {
//       // ✅ FIX: Backend sends data directly in 'data' field
//       final orderData = data['data'] as Map<String, dynamic>?;
//
//       if (orderData == null) {
//         developer.log('⚠️ No data field in event', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       // ✅ Extract order ID from multiple possible locations
//       final orderId = _extractOrderId(orderData);
//
//       developer.log('📊 Extracted orderId: $orderId', name: 'AcceptOrders.Socket');
//       developer.log('📦 Event type: ${data['type']}', name: 'AcceptOrders.Socket');
//
//       if (orderId == null || orderId == 0) {
//         developer.log('⚠️ Invalid order ID', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       // ✅ FIX: Simpler deduplication using orderId + timestamp
//       final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
//       final eventId = 'new-order-$orderId-${timestamp.substring(0, 19)}'; // Use seconds precision
//
//       if (_isDuplicateEvent(eventId)) {
//         developer.log('⏭️ Duplicate event: $eventId', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       developer.log(
//         '📥 Processing new order #$orderId',
//         name: 'AcceptOrders.Socket',
//       );
//
//       // ✅ NEW FIX: Add 1-second delay to allow DB transaction to commit
//       developer.log(
//         '⏳ Scheduling API call in 1 second to allow DB commit',
//         name: 'AcceptOrders.Socket',
//       );
//
//       Future.delayed(const Duration(seconds: 1), () {
//         developer.log(
//           '⏰ 1-second delay completed, now triggering API call for order #$orderId',
//           name: 'AcceptOrders.Socket',
//         );
//
//         // Call the API directly without additional debouncing
//         fetchPendingOrdersWithNotification(orderId, isItemsAdded: false);
//       });
//
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Error in _handleNewOrder: $e\n$stackTrace',
//         name: 'AcceptOrders.Socket.Error',
//       );
//     }
//   }
//
//
//
//
//
//   void _handleOrderStatusUpdate(dynamic rawData) {
//     developer.log('📊 ORDER STATUS UPDATE EVENT', name: 'AcceptOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     try {
//       final orderData = data['data'] as Map<String, dynamic>?;
//       if (orderData == null) return;
//
//       final orderId = _extractOrderId(orderData);
//       final newStatus = orderData['status'] as String?;
//
//       developer.log('Status: $newStatus for order #$orderId', name: 'AcceptOrders.Socket');
//
//       if (orderId == null || orderId == 0 || newStatus == null) {
//         developer.log('⚠️ Invalid order status data', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       // ✅ If order is no longer pending, remove it immediately
//       if (newStatus != 'pending') {
//         final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//         if (orderIndex != -1) {
//           ordersData.removeAt(orderIndex);
//           _notifiedOrders.remove(orderId);
//           ordersData.refresh();
//           developer.log(
//             '✅ Removed order #$orderId (status: $newStatus)',
//             name: 'AcceptOrders.Socket',
//           );
//         }
//       } else {
//         // Still pending, refresh to get latest data
//         _debouncedRefreshOrders();
//       }
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Error handling order status update: $e\n$stackTrace',
//         name: 'AcceptOrders.Socket.Error',
//       );
//     }
//   }
//
//   void _handleItemStatusUpdate(dynamic rawData) {
//     developer.log('🍽️ ITEM STATUS UPDATE EVENT', name: 'AcceptOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     try {
//       final itemData = data['data'] as Map<String, dynamic>?;
//       if (itemData == null) {
//         developer.log('⚠️ No item data', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       final orderId = _extractOrderId(itemData);
//       final itemId = _extractItemId(itemData);
//       final newStatus = itemData['status'] as String? ??
//           itemData['newStatus'] as String? ??
//           itemData['item_status'] as String?;
//
//       developer.log(
//         '🍽️ Item #$itemId status: $newStatus for order #$orderId',
//         name: 'AcceptOrders.Socket',
//       );
//
//       if (orderId == null || orderId == 0 || itemId == null || itemId == 0 || newStatus == null) {
//         developer.log('⚠️ Invalid item status data', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       // ✅ Remove from processing state immediately
//       processingItems.remove(itemId);
//
//       // ✅ If item is no longer pending, remove it from local state
//       if (newStatus != 'pending') {
//         developer.log(
//           '🚀 Removing item #$itemId (status: $newStatus)',
//           name: 'AcceptOrders.Socket',
//         );
//
//         _removeItemFromOrder(orderId, itemId);
//
//         // Background refresh for consistency
//         _debouncedRefreshOrders();
//       }
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Error handling item status update: $e\n$stackTrace',
//         name: 'AcceptOrders.Socket.Error',
//       );
//       _debouncedRefreshOrders();
//     }
//   }
//
//   void _handleNewItemsAdded(dynamic rawData) {
//     developer.log('➕ NEW ITEMS ADDED EVENT', name: 'AcceptOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     try {
//       final orderData = data['data'] as Map<String, dynamic>?;
//       if (orderData == null) return;
//
//       final orderId = _extractOrderId(orderData);
//       final newItemsCount = (orderData['items_count'] as int?) ??
//           (orderData['new_items'] as List?)?.length ??
//           0;
//
//       developer.log(
//         '📥 $newItemsCount new items added to order #$orderId',
//         name: 'AcceptOrders.Socket',
//       );
//
//       if (orderId == null || orderId == 0) {
//         developer.log('⚠️ Invalid order ID', name: 'AcceptOrders.Socket');
//         return;
//       }
//
//       // ✅ Add 1-second delay for new items too
//       developer.log(
//         '⏳ Scheduling API call in 1 second for new items',
//         name: 'AcceptOrders.Socket',
//       );
//
//       Future.delayed(const Duration(seconds: 1), () {
//         developer.log(
//           '⏰ 1-second delay completed for new items, triggering API call',
//           name: 'AcceptOrders.Socket',
//         );
//         fetchPendingOrdersWithNotification(orderId, isItemsAdded: true);
//       });
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Error handling new items added: $e\n$stackTrace',
//         name: 'AcceptOrders.Socket.Error',
//       );
//     }
//   }
//
//   void _handleTestNotification(dynamic rawData) {
//     developer.log('🧪 TEST NOTIFICATION RECEIVED', name: 'AcceptOrders.Socket');
//
//     final data = _parseSocketData(rawData);
//     if (data != null) {
//       developer.log('Test data: ${data.toString()}', name: 'AcceptOrders.Socket');
//     }
//   }
//
//   void _handleGenericUpdate(dynamic rawData) {
//     developer.log('📊 Generic update event', name: 'AcceptOrders.Socket');
//     _debouncedRefreshOrders();
//   }
//
//   /// ==================== HELPER METHODS ====================
//
//   Map<String, dynamic>? _parseSocketData(dynamic rawData) {
//     try {
//       if (rawData == null) {
//         developer.log('⚠️ Null data received', name: 'AcceptOrders.Socket');
//         return null;
//       }
//
//       if (rawData is Map) {
//         return Map<String, dynamic>.from(rawData);
//       }
//
//       if (rawData is String) {
//         // Try to parse JSON string
//         try {
//           final decoded = jsonDecode(rawData);
//           if (decoded is Map) {
//             return Map<String, dynamic>.from(decoded);
//           }
//         } catch (e) {
//           developer.log('Failed to parse JSON string: $e', name: 'AcceptOrders.Socket');
//         }
//       }
//
//       developer.log('⚠️ Unexpected data type: ${rawData.runtimeType}', name: 'AcceptOrders.Socket');
//       return {};
//     } catch (e) {
//       developer.log('❌ Parse error: $e', name: 'AcceptOrders.Socket.Error');
//       return null;
//     }
//   }
//
//   bool _isDuplicateEvent(String eventId) {
//     if (_processedEvents.contains(eventId)) {
//       return true;
//     }
//
//     _processedEvents.add(eventId);
//
//     // Keep cache size reasonable
//     if (_processedEvents.length > 100) {
//       final oldEvents = _processedEvents.toList().sublist(0, 50);
//       for (var event in oldEvents) {
//         _processedEvents.remove(event);
//       }
//     }
//
//     return false;
//   }
//
//   int? _extractOrderId(Map<String, dynamic>? data) {
//     if (data == null) return null;
//
//     // Try all possible field names
//     final id = data['order_id'] ??
//         data['orderId'] ??
//         data['id'] ??
//         data['orderid'];
//
//     if (id == null) return null;
//
//     return id is int ? id : int.tryParse(id.toString());
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
//   void _removeItemFromOrder(int orderId, int itemId) {
//     try {
//       final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
//
//       if (orderIndex != -1) {
//         final order = ordersData[orderIndex];
//         order.items.removeWhere((item) => item.id == itemId);
//
//         if (order.items.isEmpty) {
//           ordersData.removeAt(orderIndex);
//           _notifiedOrders.remove(orderId);
//           developer.log(
//             '✅ Removed order #$orderId (no pending items)',
//             name: 'AcceptOrders',
//           );
//         } else {
//           ordersData[orderIndex] = order;
//           ordersData.refresh();
//           developer.log(
//             '✅ Updated order #$orderId (removed item #$itemId)',
//             name: 'AcceptOrders',
//           );
//         }
//       }
//     } catch (e, stackTrace) {
//       developer.log('❌ Remove item error: $e\n$stackTrace', name: 'AcceptOrders.Error');
//     }
//   }
//
//   void _debouncedRefreshOrders() {
//     developer.log(
//       '🔄 Debouncing refresh (${_refreshDebounceDelay.inMilliseconds}ms)',
//       name: 'AcceptOrders.Socket',
//     );
//
//     _refreshDebounceTimer?.cancel();
//
//     _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
//       developer.log('⏰ Debounce timer fired', name: 'AcceptOrders.Socket');
//       if (!_isRefreshing) {
//         fetchPendingOrders();
//       }
//     });
//   }
//
//   void _debouncedRefreshOrdersWithNotification(int orderId, {bool isItemsAdded = false}) {
//     developer.log(
//       '🔄 Debouncing refresh with notification',
//       name: 'AcceptOrders.Socket',
//     );
//
//     _refreshDebounceTimer?.cancel();
//
//     _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
//       if (!_isRefreshing) {
//         fetchPendingOrdersWithNotification(orderId, isItemsAdded: isItemsAdded);
//       }
//     });
//   }
//
//   /// ==================== API METHODS ====================
//
//   Future<void> fetchPendingOrdersWithNotification(
//       int triggeredOrderId, {
//         bool isItemsAdded = false,
//       }) async {
//     if (_isRefreshing) {
//       developer.log('⏭️ Already refreshing', name: 'AcceptOrders');
//       return;
//     }
//
//     try {
//       _isRefreshing = true;
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       developer.log(
//         '📡 Fetching orders - attempt ${_retryAttempts + 1}',
//         name: 'AcceptOrders',
//       );
//
//       final groupedOrders = await _repository.getPendingOrders();
//
//       developer.log(
//         '✅ Fetched ${groupedOrders.length} orders',
//         name: 'AcceptOrders',
//       );
//
//       final triggeredOrder = groupedOrders.firstWhereOrNull(
//               (order) => order.orderId == triggeredOrderId
//       );
//
//       // ✅ Retry if order not found and retries available
//       if (triggeredOrder == null && _retryAttempts < _maxRetryAttempts) {
//         _retryAttempts++;
//         final retryDelay = Duration(milliseconds: 500 * _retryAttempts);
//
//         developer.log(
//           '⚠️ Order #$triggeredOrderId not found - retry $_retryAttempts/$_maxRetryAttempts in ${retryDelay.inMilliseconds}ms',
//           name: 'AcceptOrders',
//         );
//
//         _isRefreshing = false;
//         isLoading.value = false;
//
//         _retryTimer?.cancel();
//         _retryTimer = Timer(retryDelay, () {
//           fetchPendingOrdersWithNotification(triggeredOrderId, isItemsAdded: isItemsAdded);
//         });
//
//         return;
//       }
//
//       // Reset retry counter
//       _retryAttempts = 0;
//
//       ordersData.value = groupedOrders;
//       ordersData.refresh();
//
//       // Show notification if order found and not already notified
//       if (triggeredOrder != null) {
//         if (!_notifiedOrders.contains(triggeredOrderId)) {
//           _notifiedOrders.add(triggeredOrderId);
//
//           if (_notifiedOrders.length > 50) {
//             _notifiedOrders.clear();
//           }
//
//           await showGroupedOrderNotification(
//             groupedOrder: triggeredOrder,
//             isItemsAdded: isItemsAdded,
//           );
//
//           developer.log(
//             '✅ Notification shown for order #${triggeredOrder.orderId}',
//             name: 'AcceptOrders',
//           );
//         }
//       } else {
//         developer.log(
//           '⚠️ Order #$triggeredOrderId not found after retries',
//           name: 'AcceptOrders',
//         );
//       }
//     } catch (e, stackTrace) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error fetching orders: $e\n$stackTrace',
//         name: 'AcceptOrders.Error',
//       );
//
//       // Retry on error
//       if (_retryAttempts < _maxRetryAttempts) {
//         _retryAttempts++;
//         _isRefreshing = false;
//         isLoading.value = false;
//
//         _retryTimer?.cancel();
//         _retryTimer = Timer(Duration(milliseconds: 1000), () {
//           fetchPendingOrdersWithNotification(triggeredOrderId, isItemsAdded: isItemsAdded);
//         });
//       }
//     } finally {
//       if (_retryAttempts >= _maxRetryAttempts || ordersData.isNotEmpty) {
//         isLoading.value = false;
//         _isRefreshing = false;
//         _retryAttempts = 0;
//       }
//     }
//   }
//
//   Future<void> fetchPendingOrders({bool isRefresh = false}) async {
//     if (_isRefreshing) {
//       developer.log('⏭️ Already refreshing', name: 'AcceptOrders');
//       return;
//     }
//
//     try {
//       _isRefreshing = true;
//
//       if (isRefresh) {
//         isRefreshing.value = true;
//       } else {
//         isLoading.value = true;
//       }
//       errorMessage.value = '';
//
//       developer.log('🚀 Starting fetch - isRefresh=$isRefresh', name: 'AcceptOrders');
//       developer.log('📡 Calling repository.getPendingOrders()', name: 'AcceptOrders');
//
//       final groupedOrders = await _repository.getPendingOrders();
//
//       developer.log('✅ Fetched ${groupedOrders.length} pending orders', name: 'AcceptOrders');
//
//       ordersData.value = groupedOrders;
//       ordersData.refresh();
//
//       developer.log('✅ Fetch completed', name: 'AcceptOrders');
//     } catch (e, stackTrace) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error fetching orders: $e\n$stackTrace',
//         name: 'AcceptOrders.Error',
//       );
//     } finally {
//       isLoading.value = false;
//       isRefreshing.value = false;
//       _isRefreshing = false;
//     }
//   }
//
//   Future<void> refreshOrders() async {
//     developer.log('♻️ Manual refresh', name: 'AcceptOrders');
//     await fetchPendingOrders(isRefresh: true);
//   }
//
//   /// ==================== UI METHODS ====================
//
//   void toggleOrderExpansion(int orderId) {
//     if (expandedOrders.contains(orderId)) {
//       expandedOrders.remove(orderId);
//     } else {
//       expandedOrders.add(orderId);
//     }
//   }
//
//   Future<void> acceptItem(int orderId, int itemId) async {
//     try {
//       processingItems.add(itemId);
//       errorMessage.value = '';
//
//       await _repository.updateOrderItemStatus(
//         orderId: orderId,
//         itemId: itemId,
//         status: 'preparing',
//       );
//
//       developer.log('✅ Item #$itemId accepted', name: 'AcceptOrders');
//
//       _removeItemFromOrder(orderId, itemId);
//     } catch (e, stackTrace) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error accepting item: $e\n$stackTrace',
//         name: 'AcceptOrders.Error',
//       );
//     } finally {
//       processingItems.remove(itemId);
//     }
//   }
//
//   void showRejectDialogForItem(int orderId, int itemId) {
//     selectedOrderId.value = orderId;
//     selectedItemId.value = itemId;
//     isRejectDialogVisible.value = true;
//     reasonController.clear();
//     rejectionReason.value = '';
//     rejectionCategory.value = 'out_of_stock';
//   }
//
//   void hideRejectDialog() {
//     isRejectDialogVisible.value = false;
//     selectedOrderId.value = null;
//     selectedItemId.value = null;
//     reasonController.clear();
//     rejectionReason.value = '';
//     rejectionCategory.value = 'out_of_stock';
//   }
//
//   void updateRejectionReason(String reason) {
//     rejectionReason.value = reason;
//   }
//
//   void updateRejectionCategory(String category) {
//     rejectionCategory.value = category;
//   }
//
//   Future<void> rejectItem(BuildContext context) async {
//     if (reasonController.text.trim().isEmpty) {
//       SnackBarUtil.showWarning(
//         context,
//         'Please provide a reason for rejecting the item',
//         title: 'Reason Required',
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }
//
//     if (selectedOrderId.value == null || selectedItemId.value == null) return;
//
//     final orderId = selectedOrderId.value!;
//     final itemId = selectedItemId.value!;
//     final reason = reasonController.text.trim();
//     final category = rejectionCategory.value;
//
//     try {
//       processingItems.add(itemId);
//       errorMessage.value = '';
//
//       await _repository.rejectOrderItem(
//         orderId: orderId,
//         itemId: itemId,
//         rejectionReason: reason,
//         rejectionCategory: category,
//       );
//
//       hideRejectDialog();
//
//       SnackBarUtil.showSuccess(
//         context,
//         'Item has been rejected',
//         title: 'Item Rejected',
//         duration: const Duration(seconds: 2),
//       );
//
//       _removeItemFromOrder(orderId, itemId);
//
//       developer.log(
//         '✅ Item #$itemId rejected - Reason: $reason',
//         name: 'AcceptOrders',
//       );
//     } catch (e, stackTrace) {
//       errorMessage.value = e.toString();
//       developer.log(
//         '❌ Error rejecting item: $e\n$stackTrace',
//         name: 'AcceptOrders.Error',
//       );
//
//       SnackBarUtil.showError(
//         context,
//         'Failed to reject item: ${e.toString()}',
//         title: 'Rejection Failed',
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       processingItems.remove(itemId);
//     }
//   }
//
//   /// ==================== VALIDATION & FORMATTING ====================
//
//   String formatCurrency(double amount) {
//     return '₹${amount.toStringAsFixed(2)}';
//   }
//
//   String? validateRejectionReason(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please provide a reason for rejection';
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
//   /// ==================== DEBUG METHODS ====================
//
//   void reconnectSocket() {
//     try {
//       developer.log('🔄 Manual socket reconnection', name: 'AcceptOrders');
//
//       _socketManager.reconnect();
//
//       Future.delayed(const Duration(seconds: 2), () {
//         _listenersRegistered = false;
//         _setupSocketListeners();
//       });
//     } catch (e, stackTrace) {
//       developer.log(
//         '❌ Error reconnecting: $e\n$stackTrace',
//         name: 'AcceptOrders.Error',
//       );
//     }
//   }
//
//   String getSocketStatus() {
//     final info = _socketManager.getConnectionInfo();
//     return '''
// Socket Connected: ${info['isConnected']}
// Socket Exists: ${info['socketExists']}
// Manager Connected: ${info['managerConnected']}
// Active Listeners: ${info['activeListeners']}
// Connection In Progress: ${info['connectionInProgress']}
// Registered Events: ${info['registeredEvents']}
// Listeners Setup: $_listenersRegistered
// Retry Attempts: $_retryAttempts/$_maxRetryAttempts
// Refresh Timer Active: ${_refreshDebounceTimer?.isActive ?? false}
// Retry Timer Active: ${_retryTimer?.isActive ?? false}
//     ''';
//   }
//
//   /// ==================== GETTERS ====================
//
//   bool get socketConnected => isSocketConnected.value;
//   int get totalPendingOrders => ordersData.length;
//   int get totalPendingItems =>
//       ordersData.fold(0, (sum, order) => sum + order.totalItemsCount);
//   Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/repositories/pending_orders_repository.dart';
import '../../../data/models/ResponseModel/pending_orders_model.dart';
import '../../service/socket_connection_manager.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/notifications_widget.dart';

class AcceptOrderController extends GetxController {
  final PendingOrdersRepository _repository;
  final notificationService = NotificationService.instance;

  AcceptOrderController({PendingOrdersRepository? repository})
      : _repository = repository ?? PendingOrdersRepository();

  // Reactive state variables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final ordersData = <GroupedOrder>[].obs;
  final errorMessage = ''.obs;
  final rejectionReason = ''.obs;
  final rejectionCategory = 'out_of_stock'.obs;
  final isRejectDialogVisible = false.obs;
  final selectedOrderId = Rxn<int>();
  final selectedItemId = Rxn<int>();
  final expandedOrders = <int>{}.obs;
  final processingItems = <int>{}.obs;
  final isSocketConnected = false.obs;

  final TextEditingController reasonController = TextEditingController();

  // Socket & debounce
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;

  Timer? _refreshDebounceTimer;
  Timer? _retryTimer;
  final _refreshDebounceDelay = const Duration(milliseconds: 2000);

  bool _isRefreshing = false;
  final Set<String> _processedEvents = {};
  final Set<int> _notifiedOrders = {};

  // Retry logic variables
  int _retryAttempts = 0;
  final _maxRetryAttempts = 3;

  // Track if listeners are setup
  bool _listenersRegistered = false;

  @override
  void onInit() {
    super.onInit();
    developer.log('AcceptOrderController initialized', name: 'AcceptOrders');

    // Setup socket listeners first
    _setupSocketListeners();
    isSocketConnected.value = _socketManager.connectionStatus;

    // Monitor socket connection state
    ever(_socketManager.isConnected, _onSocketConnectionChanged);

    // Fetch orders after socket setup
    fetchPendingOrders();
  }

  @override
  void onClose() {
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;

    _removeSocketListeners();
    reasonController.dispose();

    developer.log('AcceptOrderController disposed - all timers cancelled', name: 'AcceptOrders');
    super.onClose();
  }

  /// ==================== SOCKET SETUP ====================

  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'AcceptOrders.Socket');

    final socket = _socketManager.socketService.socket;
    if (socket == null) {
      developer.log('⚠️ Socket is NULL - scheduling retry', name: 'AcceptOrders.Socket');
      Future.delayed(Duration(seconds: 1), () {
        if (_socketManager.socketService.socket != null && !_listenersRegistered) {
          developer.log('🔄 Socket now available - retrying setup', name: 'AcceptOrders.Socket');
          _setupSocketListeners();
        }
      });
      return;
    }

    if (_listenersRegistered) {
      developer.log('⏭️ Listeners already registered, skipping', name: 'AcceptOrders.Socket');
      return;
    }

    _removeSocketListeners();

    // ✅ All socket events including order_cancelled
    final events = {
      // Primary event from backend for new orders
      'new_order': _handleNewOrder,

      // Order status updates
      'order_status_update': _handleOrderStatusUpdate,

      // Item status updates - CRITICAL for chef panel
      'item_status_update': _handleItemStatusUpdate,

      // New items added to existing order
      'new_items_added': _handleNewItemsAdded,
      'new_items_to_prepare': _handleNewItemsAdded,

      // ✅ NEW: Order cancelled events
      'order_cancelled': _handleOrderCancelled,
      'order_cancelled_alert': _handleOrderCancelled,

      // Test notifications
      'test_notification': _handleTestNotification,

      // Generic fallbacks
      'order_update': _handleGenericUpdate,
    };

    events.forEach((eventName, handler) {
      _socketManager.socketService.on(eventName, (dynamic data) {
        developer.log(
          '🎯 [SOCKET EVENT] "$eventName" received',
          name: 'AcceptOrders.Socket',
        );

        // Log raw data for debugging
        developer.log(
          '📦 Raw data type: ${data.runtimeType}',
          name: 'AcceptOrders.Socket',
        );

        try {
          handler(data);
          developer.log('✅ Handler completed: $eventName', name: 'AcceptOrders.Socket');
        } catch (e, stackTrace) {
          developer.log(
            '❌ Handler error for $eventName: $e\n$stackTrace',
            name: 'AcceptOrders.Socket.Error',
          );
        }
      });

      developer.log('✓ Registered listener: $eventName', name: 'AcceptOrders.Socket');
    });

    _listenersRegistered = true;

    developer.log(
      '✅ ${events.length} socket listeners registered',
      name: 'AcceptOrders.Socket',
    );
  }

  void _removeSocketListeners() {
    final events = [
      'new_order',
      'order_status_update',
      'item_status_update',
      'new_items_added',
      'new_items_to_prepare',
      'order_cancelled',
      'order_cancelled_alert',
      'test_notification',
      'order_update',
    ];

    for (var event in events) {
      _socketManager.socketService.off(event);
    }

    _listenersRegistered = false;
    developer.log('✅ Socket listeners removed', name: 'AcceptOrders.Socket');
  }

  void _onSocketConnectionChanged(bool connected) {
    isSocketConnected.value = connected;
    developer.log('Socket connection changed: $connected', name: 'AcceptOrders.Socket');

    if (connected) {
      developer.log('🔄 Socket reconnected - re-registering listeners', name: 'AcceptOrders.Socket');
      _listenersRegistered = false;
      _setupSocketListeners();
      _debouncedRefreshOrders();
    }
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  void _handleNewOrder(dynamic rawData) {
    developer.log('🔔 NEW ORDER EVENT RECEIVED', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) {
      developer.log('❌ Failed to parse socket data', name: 'AcceptOrders.Socket');
      return;
    }

    try {
      final orderData = data['data'] as Map<String, dynamic>?;

      if (orderData == null) {
        developer.log('⚠️ No data field in event', name: 'AcceptOrders.Socket');
        return;
      }

      final orderId = _extractOrderId(orderData);

      developer.log('📊 Extracted orderId: $orderId', name: 'AcceptOrders.Socket');
      developer.log('📦 Event type: ${data['type']}', name: 'AcceptOrders.Socket');

      if (orderId == null || orderId == 0) {
        developer.log('⚠️ Invalid order ID', name: 'AcceptOrders.Socket');
        return;
      }

      final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
      final eventId = 'new-order-$orderId-${timestamp.substring(0, 19)}';

      if (_isDuplicateEvent(eventId)) {
        developer.log('⏭️ Duplicate event: $eventId', name: 'AcceptOrders.Socket');
        return;
      }

      developer.log(
        '📥 Processing new order #$orderId',
        name: 'AcceptOrders.Socket',
      );

      developer.log(
        '⏳ Scheduling API call in 1 second to allow DB commit',
        name: 'AcceptOrders.Socket',
      );

      Future.delayed(const Duration(seconds: 1), () {
        developer.log(
          '⏰ 1-second delay completed, now triggering API call for order #$orderId',
          name: 'AcceptOrders.Socket',
        );

        fetchPendingOrdersWithNotification(orderId, isItemsAdded: false);
      });

    } catch (e, stackTrace) {
      developer.log(
        '❌ Error in _handleNewOrder: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleOrderStatusUpdate(dynamic rawData) {
    developer.log('📊 ORDER STATUS UPDATE EVENT', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) return;

    try {
      final orderData = data['data'] as Map<String, dynamic>?;
      if (orderData == null) return;

      final orderId = _extractOrderId(orderData);
      final newStatus = orderData['status'] as String?;

      developer.log('Status: $newStatus for order #$orderId', name: 'AcceptOrders.Socket');

      if (orderId == null || orderId == 0 || newStatus == null) {
        developer.log('⚠️ Invalid order status data', name: 'AcceptOrders.Socket');
        return;
      }

      if (newStatus != 'pending') {
        final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
        if (orderIndex != -1) {
          ordersData.removeAt(orderIndex);
          _notifiedOrders.remove(orderId);
          ordersData.refresh();
          developer.log(
            '✅ Removed order #$orderId (status: $newStatus)',
            name: 'AcceptOrders.Socket',
          );
        }
      } else {
        _debouncedRefreshOrders();
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling order status update: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleItemStatusUpdate(dynamic rawData) {
    developer.log('🍽️ ITEM STATUS UPDATE EVENT', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) return;

    try {
      final itemData = data['data'] as Map<String, dynamic>?;
      if (itemData == null) {
        developer.log('⚠️ No item data', name: 'AcceptOrders.Socket');
        return;
      }

      final orderId = _extractOrderId(itemData);
      final itemId = _extractItemId(itemData);
      final newStatus = itemData['status'] as String? ??
          itemData['newStatus'] as String? ??
          itemData['item_status'] as String?;

      developer.log(
        '🍽️ Item #$itemId status: $newStatus for order #$orderId',
        name: 'AcceptOrders.Socket',
      );

      if (orderId == null || orderId == 0 || itemId == null || itemId == 0 || newStatus == null) {
        developer.log('⚠️ Invalid item status data', name: 'AcceptOrders.Socket');
        return;
      }

      processingItems.remove(itemId);

      if (newStatus != 'pending') {
        developer.log(
          '🚀 Removing item #$itemId (status: $newStatus)',
          name: 'AcceptOrders.Socket',
        );

        _removeItemFromOrder(orderId, itemId);
        _debouncedRefreshOrders();
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling item status update: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
      _debouncedRefreshOrders();
    }
  }

  void _handleNewItemsAdded(dynamic rawData) {
    developer.log('➕ NEW ITEMS ADDED EVENT', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) return;

    try {
      final orderData = data['data'] as Map<String, dynamic>?;
      if (orderData == null) return;

      final orderId = _extractOrderId(orderData);
      final newItemsCount = (orderData['items_count'] as int?) ??
          (orderData['new_items'] as List?)?.length ??
          0;

      developer.log(
        '📥 $newItemsCount new items added to order #$orderId',
        name: 'AcceptOrders.Socket',
      );

      if (orderId == null || orderId == 0) {
        developer.log('⚠️ Invalid order ID', name: 'AcceptOrders.Socket');
        return;
      }

      developer.log(
        '⏳ Scheduling API call in 1 second for new items',
        name: 'AcceptOrders.Socket',
      );

      Future.delayed(const Duration(seconds: 1), () {
        developer.log(
          '⏰ 1-second delay completed for new items, triggering API call',
          name: 'AcceptOrders.Socket',
        );
        fetchPendingOrdersWithNotification(orderId, isItemsAdded: true);
      });
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error handling new items added: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  // ✅ NEW: Handle order cancelled event
  void _handleOrderCancelled(dynamic rawData) {
    developer.log('🚫 ORDER CANCELLED EVENT RECEIVED', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) {
      developer.log('❌ Failed to parse order cancelled data', name: 'AcceptOrders.Socket');
      return;
    }

    try {
      // Extract order information from the event
      final orderId = _extractOrderId(data) ??
          (data['orderId'] as int?) ??
          (data['order_id'] as int?);

      final orderNumber = data['order_number'] as String? ??
          data['bill_number'] as String? ??
          'Order #$orderId';

      final cancelledBy = data['cancelled_by'] as String? ?? 'Manager';

      final customerName = data['customer_name'] as String? ?? 'Customer';

      final tableNumber = data['table_number']?.toString() ?? '';

      final affectedItemsCount = data['affected_items_count'] as int? ?? 0;

      developer.log(
        '🚫 Order cancelled: $orderNumber (ID: $orderId) by $cancelledBy',
        name: 'AcceptOrders.Socket',
      );
      developer.log(
        '📋 Customer: $customerName, Table: $tableNumber, Items: $affectedItemsCount',
        name: 'AcceptOrders.Socket',
      );

      if (orderId == null || orderId == 0) {
        developer.log('⚠️ Invalid order ID in cancellation event', name: 'AcceptOrders.Socket');
        return;
      }

      // ✅ Remove order from local state immediately
      final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);
      if (orderIndex != -1) {
        ordersData.removeAt(orderIndex);
        _notifiedOrders.remove(orderId);
        expandedOrders.remove(orderId);
        ordersData.refresh();

        developer.log(
          '✅ Removed cancelled order #$orderId from local state',
          name: 'AcceptOrders.Socket',
        );

        // ✅ Show snackbar notification
        final context = Get.context;
        if (context != null) {
          SnackBarUtil.showWarning(
            context,
            '⚠️ Order $orderNumber has been cancelled by $cancelledBy${tableNumber.isNotEmpty ? ' (Table $tableNumber)' : ''}',
            title: 'Order Cancelled',
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        developer.log(
          '⚠️ Order #$orderId not found in local state (already removed or not loaded)',
          name: 'AcceptOrders.Socket',
        );
      }

      // ✅ Trigger manual refresh to sync with backend
      developer.log(
        '🔄 Triggering manual refresh after order cancellation',
        name: 'AcceptOrders.Socket',
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        refreshOrders();
      });

    } catch (e, stackTrace) {
      developer.log(
        '❌ Error in _handleOrderCancelled: $e\n$stackTrace',
        name: 'AcceptOrders.Socket.Error',
      );
    }
  }

  void _handleTestNotification(dynamic rawData) {
    developer.log('🧪 TEST NOTIFICATION RECEIVED', name: 'AcceptOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data != null) {
      developer.log('Test data: ${data.toString()}', name: 'AcceptOrders.Socket');
    }
  }

  void _handleGenericUpdate(dynamic rawData) {
    developer.log('📊 Generic update event', name: 'AcceptOrders.Socket');
    _debouncedRefreshOrders();
  }

  /// ==================== HELPER METHODS ====================

  Map<String, dynamic>? _parseSocketData(dynamic rawData) {
    try {
      if (rawData == null) {
        developer.log('⚠️ Null data received', name: 'AcceptOrders.Socket');
        return null;
      }

      if (rawData is Map) {
        return Map<String, dynamic>.from(rawData);
      }

      if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          developer.log('Failed to parse JSON string: $e', name: 'AcceptOrders.Socket');
        }
      }

      developer.log('⚠️ Unexpected data type: ${rawData.runtimeType}', name: 'AcceptOrders.Socket');
      return {};
    } catch (e) {
      developer.log('❌ Parse error: $e', name: 'AcceptOrders.Socket.Error');
      return null;
    }
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      return true;
    }

    _processedEvents.add(eventId);

    if (_processedEvents.length > 100) {
      final oldEvents = _processedEvents.toList().sublist(0, 50);
      for (var event in oldEvents) {
        _processedEvents.remove(event);
      }
    }

    return false;
  }

  int? _extractOrderId(Map<String, dynamic>? data) {
    if (data == null) return null;

    final id = data['order_id'] ??
        data['orderId'] ??
        data['id'] ??
        data['orderid'];

    if (id == null) return null;

    return id is int ? id : int.tryParse(id.toString());
  }

  int? _extractItemId(Map<String, dynamic>? data) {
    if (data == null) return null;

    final id = data['itemId'] ??
        data['item_id'] ??
        data['id'];

    if (id == null) return null;

    return id is int ? id : int.tryParse(id.toString());
  }

  void _removeItemFromOrder(int orderId, int itemId) {
    try {
      final orderIndex = ordersData.indexWhere((o) => o.orderId == orderId);

      if (orderIndex != -1) {
        final order = ordersData[orderIndex];
        order.items.removeWhere((item) => item.id == itemId);

        if (order.items.isEmpty) {
          ordersData.removeAt(orderIndex);
          _notifiedOrders.remove(orderId);
          developer.log(
            '✅ Removed order #$orderId (no pending items)',
            name: 'AcceptOrders',
          );
        } else {
          ordersData[orderIndex] = order;
          ordersData.refresh();
          developer.log(
            '✅ Updated order #$orderId (removed item #$itemId)',
            name: 'AcceptOrders',
          );
        }
      }
    } catch (e, stackTrace) {
      developer.log('❌ Remove item error: $e\n$stackTrace', name: 'AcceptOrders.Error');
    }
  }

  void _debouncedRefreshOrders() {
    developer.log(
      '🔄 Debouncing refresh (${_refreshDebounceDelay.inMilliseconds}ms)',
      name: 'AcceptOrders.Socket',
    );

    _refreshDebounceTimer?.cancel();

    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      developer.log('⏰ Debounce timer fired', name: 'AcceptOrders.Socket');
      if (!_isRefreshing) {
        fetchPendingOrders();
      }
    });
  }

  void _debouncedRefreshOrdersWithNotification(int orderId, {bool isItemsAdded = false}) {
    developer.log(
      '🔄 Debouncing refresh with notification',
      name: 'AcceptOrders.Socket',
    );

    _refreshDebounceTimer?.cancel();

    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      if (!_isRefreshing) {
        fetchPendingOrdersWithNotification(orderId, isItemsAdded: isItemsAdded);
      }
    });
  }

  /// ==================== API METHODS ====================

  Future<void> fetchPendingOrdersWithNotification(
      int triggeredOrderId, {
        bool isItemsAdded = false,
      }) async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing', name: 'AcceptOrders');
      return;
    }

    try {
      _isRefreshing = true;
      isLoading.value = true;
      errorMessage.value = '';

      developer.log(
        '📡 Fetching orders - attempt ${_retryAttempts + 1}',
        name: 'AcceptOrders',
      );

      final groupedOrders = await _repository.getPendingOrders();

      developer.log(
        '✅ Fetched ${groupedOrders.length} orders',
        name: 'AcceptOrders',
      );

      final triggeredOrder = groupedOrders.firstWhereOrNull(
              (order) => order.orderId == triggeredOrderId
      );

      if (triggeredOrder == null && _retryAttempts < _maxRetryAttempts) {
        _retryAttempts++;
        final retryDelay = Duration(milliseconds: 500 * _retryAttempts);

        developer.log(
          '⚠️ Order #$triggeredOrderId not found - retry $_retryAttempts/$_maxRetryAttempts in ${retryDelay.inMilliseconds}ms',
          name: 'AcceptOrders',
        );

        _isRefreshing = false;
        isLoading.value = false;

        _retryTimer?.cancel();
        _retryTimer = Timer(retryDelay, () {
          fetchPendingOrdersWithNotification(triggeredOrderId, isItemsAdded: isItemsAdded);
        });

        return;
      }

      _retryAttempts = 0;

      ordersData.value = groupedOrders;
      ordersData.refresh();

      if (triggeredOrder != null) {
        if (!_notifiedOrders.contains(triggeredOrderId)) {
          _notifiedOrders.add(triggeredOrderId);

          if (_notifiedOrders.length > 50) {
            _notifiedOrders.clear();
          }

          await showGroupedOrderNotification(
            groupedOrder: triggeredOrder,
            isItemsAdded: isItemsAdded,
          );

          developer.log(
            '✅ Notification shown for order #${triggeredOrder.orderId}',
            name: 'AcceptOrders',
          );
        }
      } else {
        developer.log(
          '⚠️ Order #$triggeredOrderId not found after retries',
          name: 'AcceptOrders',
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error fetching orders: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );

      if (_retryAttempts < _maxRetryAttempts) {
        _retryAttempts++;
        _isRefreshing = false;
        isLoading.value = false;

        _retryTimer?.cancel();
        _retryTimer = Timer(Duration(milliseconds: 1000), () {
          fetchPendingOrdersWithNotification(triggeredOrderId, isItemsAdded: isItemsAdded);
        });
      }
    } finally {
      if (_retryAttempts >= _maxRetryAttempts || ordersData.isNotEmpty) {
        isLoading.value = false;
        _isRefreshing = false;
        _retryAttempts = 0;
      }
    }
  }

  Future<void> fetchPendingOrders({bool isRefresh = false}) async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing', name: 'AcceptOrders');
      return;
    }

    try {
      _isRefreshing = true;

      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      developer.log('🚀 Starting fetch - isRefresh=$isRefresh', name: 'AcceptOrders');
      developer.log('📡 Calling repository.getPendingOrders()', name: 'AcceptOrders');

      final groupedOrders = await _repository.getPendingOrders();

      developer.log('✅ Fetched ${groupedOrders.length} pending orders', name: 'AcceptOrders');

      ordersData.value = groupedOrders;
      ordersData.refresh();

      developer.log('✅ Fetch completed', name: 'AcceptOrders');
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error fetching orders: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      _isRefreshing = false;
    }
  }

  Future<void> refreshOrders() async {
    developer.log('♻️ Manual refresh', name: 'AcceptOrders');
    await fetchPendingOrders(isRefresh: true);
  }

  /// ==================== UI METHODS ====================

  void toggleOrderExpansion(int orderId) {
    if (expandedOrders.contains(orderId)) {
      expandedOrders.remove(orderId);
    } else {
      expandedOrders.add(orderId);
    }
  }

  Future<void> acceptItem(int orderId, int itemId) async {
    try {
      processingItems.add(itemId);
      errorMessage.value = '';

      await _repository.updateOrderItemStatus(
        orderId: orderId,
        itemId: itemId,
        status: 'preparing',
      );

      developer.log('✅ Item #$itemId accepted', name: 'AcceptOrders');

      _removeItemFromOrder(orderId, itemId);
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error accepting item: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );
    } finally {
      processingItems.remove(itemId);
    }
  }

  void showRejectDialogForItem(int orderId, int itemId) {
    selectedOrderId.value = orderId;
    selectedItemId.value = itemId;
    isRejectDialogVisible.value = true;
    reasonController.clear();
    rejectionReason.value = '';
    rejectionCategory.value = 'out_of_stock';
  }

  void hideRejectDialog() {
    isRejectDialogVisible.value = false;
    selectedOrderId.value = null;
    selectedItemId.value = null;
    reasonController.clear();
    rejectionReason.value = '';
    rejectionCategory.value = 'out_of_stock';
  }

  void updateRejectionReason(String reason) {
    rejectionReason.value = reason;
  }

  void updateRejectionCategory(String category) {
    rejectionCategory.value = category;
  }

  Future<void> rejectItem(BuildContext context) async {
    if (reasonController.text.trim().isEmpty) {
      SnackBarUtil.showWarning(
        context,
        'Please provide a reason for rejecting the item',
        title: 'Reason Required',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedOrderId.value == null || selectedItemId.value == null) return;

    final orderId = selectedOrderId.value!;
    final itemId = selectedItemId.value!;
    final reason = reasonController.text.trim();
    final category = rejectionCategory.value;

    try {
      processingItems.add(itemId);
      errorMessage.value = '';

      await _repository.rejectOrderItem(
        orderId: orderId,
        itemId: itemId,
        rejectionReason: reason,
        rejectionCategory: category,
      );

      hideRejectDialog();

      SnackBarUtil.showSuccess(
        context,
        'Item has been rejected',
        title: 'Item Rejected',
        duration: const Duration(seconds: 2),
      );

      _removeItemFromOrder(orderId, itemId);

      developer.log(
        '✅ Item #$itemId rejected - Reason: $reason',
        name: 'AcceptOrders',
      );
    } catch (e, stackTrace) {
      errorMessage.value = e.toString();
      developer.log(
        '❌ Error rejecting item: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );

      SnackBarUtil.showError(
        context,
        'Failed to reject item: ${e.toString()}',
        title: 'Rejection Failed',
        duration: const Duration(seconds: 3),
      );
    } finally {
      processingItems.remove(itemId);
    }
  }

  /// ==================== VALIDATION & FORMATTING ====================

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String? validateRejectionReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a reason for rejection';
    }
    if (value.trim().length < 10) {
      return 'Reason must be at least 10 characters long';
    }
    if (value.trim().length > 500) {
      return 'Reason cannot exceed 500 characters';
    }
    return null;
  }

  /// ==================== DEBUG METHODS ====================

  void reconnectSocket() {
    try {
      developer.log('🔄 Manual socket reconnection', name: 'AcceptOrders');

      _socketManager.reconnect();

      Future.delayed(const Duration(seconds: 2), () {
        _listenersRegistered = false;
        _setupSocketListeners();
      });
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error reconnecting: $e\n$stackTrace',
        name: 'AcceptOrders.Error',
      );
    }
  }

  String getSocketStatus() {
    final info = _socketManager.getConnectionInfo();
    return '''
Socket Connected: ${info['isConnected']}
Socket Exists: ${info['socketExists']}
Manager Connected: ${info['managerConnected']}
Active Listeners: ${info['activeListeners']}
Connection In Progress: ${info['connectionInProgress']}
Registered Events: ${info['registeredEvents']}
Listeners Setup: $_listenersRegistered
Retry Attempts: $_retryAttempts/$_maxRetryAttempts
Refresh Timer Active: ${_refreshDebounceTimer?.isActive ?? false}
Retry Timer Active: ${_retryTimer?.isActive ?? false}
    ''';
  }

  /// ==================== GETTERS ====================

  bool get socketConnected => isSocketConnected.value;
  int get totalPendingOrders => ordersData.length;
  int get totalPendingItems =>
      ordersData.fold(0, (sum, order) => sum + order.totalItemsCount);
  Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
}