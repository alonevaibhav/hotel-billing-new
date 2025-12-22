// import 'package:get/get.dart';
// import 'dart:developer' as developer;
// import '../../modules/controllers/WaiterPanelController/ready_order_controller.dart';
// import '../../modules/service/socket_connection_manager.dart';
// import 'notification_service.dart';
//
// /// Global service that listens to order events and triggers notifications
// /// This service stays alive throughout the app lifecycle
// /// Notifications will work on ANY page in the app
// class OrderNotificationService extends GetxService {
//   static OrderNotificationService get instance => Get.find<OrderNotificationService>();
//
//   final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
//   final NotificationService _notificationService = NotificationService.instance;
//
//   final Set<String> _processedEvents = {};
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('🔔 OrderNotificationService initialized - Global notifications enabled',
//         name: 'OrderNotificationService');
//     _setupSocketListeners();  // ✅ MUST BE UNCOMMENTED
//   }
//
//   @override
//   void onClose() {
//     _removeSocketListeners();
//     developer.log('OrderNotificationService disposed', name: 'OrderNotificationService');
//     super.onClose();
//   }
//
//   /// Setup socket listeners for order events - Works globally
//   void _setupSocketListeners() {
//     developer.log('🔌 Setting up GLOBAL socket listeners', name: 'OrderNotificationService');
//
//     final eventHandlers = {
//       'order_ready_to_serve': _handleOrderReadyToServe,
//       'order_status_update': _handleOrderStatusUpdate,
//       'order_served': _handleOrderServed,
//       'order_completed': _handleOrderCompleted,
//       'item_ready': _handleItemReady,
//       'new_order': _handleNewOrder,
//     };
//
//     eventHandlers.forEach((event, handler) {
//       _socketManager.socketService.on(event, handler);
//       developer.log('✅ Registered GLOBAL listener for: $event', name: 'OrderNotificationService');
//     });
//
//     developer.log('✅ ${eventHandlers.length} GLOBAL socket listeners active',
//         name: 'OrderNotificationService');
//   }
//
//   void _removeSocketListeners() {
//     final events = [
//       'order_ready_to_serve',
//       'order_status_update',
//       'order_served',
//       'order_completed',
//       'item_ready',
//       'new_order',
//     ];
//     events.forEach(_socketManager.socketService.off);
//     developer.log('✅ Global socket listeners removed', name: 'OrderNotificationService');
//   }
//
//   /// Handle new order event
//   void _handleNewOrder(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('🆕 GLOBAL: New order event', name: 'OrderNotificationService');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//
//     // Show notification
//     _showNewOrderNotification(orderId, tableNumber);
//
//     // Refresh controllers if they exist
//     _refreshAllControllers();
//   }
//
//   /// Handle item ready event
//   void _handleItemReady(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('🍽️ GLOBAL: Item ready event', name: 'OrderNotificationService');
//
//     final itemData = data['data'] ?? data;
//     final orderId = _extractOrderId(itemData);
//     final tableNumber = _extractTableNumber(itemData);
//     final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
//     final eventId = 'item-ready-$orderId-$timestamp';
//
//     if (_isDuplicateEvent(eventId)) return;
//
//     // Show notification - Works on ANY page
//     _showReadyToServeNotification(orderId, tableNumber);
//
//     // Refresh the controller if it exists
//     _refreshAllControllers();
//   }
//
//   /// Handle order ready to serve event
//   void _handleOrderReadyToServe(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('🍽️ GLOBAL: Order ready to serve event', name: 'OrderNotificationService');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//     final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
//     final eventId = 'ready-$orderId-$timestamp';
//
//     if (_isDuplicateEvent(eventId)) return;
//
//     // Show notification - Works on ANY page
//     _showReadyToServeNotification(orderId, tableNumber);
//
//     // Refresh controllers
//     _refreshAllControllers();
//   }
//
//   /// Handle order status update event
//   void _handleOrderStatusUpdate(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('📊 GLOBAL: Order status update event', name: 'OrderNotificationService');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final status = orderData['status'] ?? orderData['order_status'];
//     final tableNumber = _extractTableNumber(orderData);
//
//     developer.log('Status: $status for order #$orderId (Table $tableNumber)',
//         name: 'OrderNotificationService');
//
//     // Show appropriate notification based on status - Works on ANY page
//     if (status == 'ready_to_serve' || status == 'ready') {
//       _showReadyToServeNotification(orderId, tableNumber);
//     } else if (status == 'served') {
//       _showOrderServedNotification(orderId, tableNumber);
//     } else if (status == 'completed') {
//       _showOrderCompletedNotification(orderId, tableNumber);
//     }
//
//     // Refresh controllers
//     _refreshAllControllers();
//   }
//
//   /// Handle order served event
//   void _handleOrderServed(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('✅ GLOBAL: Order served event', name: 'OrderNotificationService');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//
//     _showOrderServedNotification(orderId, tableNumber);
//     _refreshAllControllers();
//   }
//
//   /// Handle order completed event
//   void _handleOrderCompleted(dynamic rawData) {
//     final data = _parseSocketData(rawData);
//     if (data == null) return;
//
//     developer.log('🎉 GLOBAL: Order completed event', name: 'OrderNotificationService');
//
//     final orderData = data['data'] ?? data;
//     final orderId = _extractOrderId(orderData);
//     final tableNumber = _extractTableNumber(orderData);
//
//     _showOrderCompletedNotification(orderId, tableNumber);
//     _refreshAllControllers();
//   }
//
//   /// ==================== NOTIFICATION METHODS ====================
//   /// These work on ANY page in the app
//
//   void _showNewOrderNotification(int orderId, String tableNumber) {
//     try {
//       _notificationService.showNotification(
//         title: '🆕 New Order',
//         body: 'Table $tableNumber - Order #$orderId received',
//         payload: 'new_order_$orderId',
//       );
//       developer.log('📱 GLOBAL Notification: New Order #$orderId',
//           name: 'OrderNotificationService');
//     } catch (e) {
//       developer.log('❌ Notification error: $e', name: 'OrderNotificationService.Error');
//     }
//   }
//
//   void _showReadyToServeNotification(int orderId, String tableNumber) {
//     try {
//       _notificationService.showNotification(
//         title: '🍽️ Order Ready',
//         body: 'Table $tableNumber - Order #$orderId is ready to serve',
//         payload: 'ready_order_$orderId',
//       );
//       developer.log('📱 GLOBAL Notification: Order #$orderId ready (Table $tableNumber)',
//           name: 'OrderNotificationService');
//     } catch (e) {
//       developer.log('❌ Notification error: $e', name: 'OrderNotificationService.Error');
//     }
//   }
//
//   void _showOrderServedNotification(int orderId, String tableNumber) {
//     try {
//       _notificationService.showNotification(
//         title: '✅ Order Served',
//         body: 'Table $tableNumber - Order #$orderId has been served',
//         payload: 'served_order_$orderId',
//       );
//       developer.log('📱 GLOBAL Notification: Order #$orderId served (Table $tableNumber)',
//           name: 'OrderNotificationService');
//     } catch (e) {
//       developer.log('❌ Notification error: $e', name: 'OrderNotificationService.Error');
//     }
//   }
//
//   void _showOrderCompletedNotification(int orderId, String tableNumber) {
//     try {
//       _notificationService.showNotification(
//         title: '🎉 Order Completed',
//         body: 'Table $tableNumber - Order #$orderId is completed',
//         payload: 'completed_order_$orderId',
//       );
//       developer.log('📱 GLOBAL Notification: Order #$orderId completed (Table $tableNumber)',
//           name: 'OrderNotificationService');
//     } catch (e) {
//       developer.log('❌ Notification error: $e', name: 'OrderNotificationService.Error');
//     }
//   }
//
//   /// ==================== REFRESH CONTROLLERS ====================
//   /// Refresh any active controllers that need updated data
//
//   void _refreshAllControllers() {
//     // Refresh ReadyOrderController if it exists
//     try {
//       if (Get.isRegistered<ReadyOrderController>()) {
//         final controller = Get.find<ReadyOrderController>();
//         controller.fetchReadyOrders();
//         developer.log('🔄 ReadyOrderController refreshed', name: 'OrderNotificationService');
//       }
//     } catch (e) {
//       developer.log('⚠️ Could not refresh ReadyOrderController: $e',
//           name: 'OrderNotificationService');
//     }
//
//     // Add more controller refreshes here if needed
//     // Example: TakeOrderController, etc.
//   }
//
//   /// ==================== HELPER METHODS ====================
//
//   Map<String, dynamic>? _parseSocketData(dynamic rawData) {
//     try {
//       return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
//     } catch (e) {
//       developer.log('❌ Parse error: $e', name: 'OrderNotificationService.Error');
//       return null;
//     }
//   }
//
//   bool _isDuplicateEvent(String eventId) {
//     if (_processedEvents.contains(eventId)) {
//       developer.log('⏭️ SKIPPING duplicate: $eventId', name: 'OrderNotificationService');
//       return true;
//     }
//     _processedEvents.add(eventId);
//     // Keep only last 100 events to prevent memory issues
//     if (_processedEvents.length > 100) {
//       _processedEvents.clear();
//     }
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
// }