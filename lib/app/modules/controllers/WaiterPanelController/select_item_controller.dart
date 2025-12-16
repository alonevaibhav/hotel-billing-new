//
//
// import 'package:flutter/material.dart' hide Table;
// import 'package:get/get.dart';
// import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
// import 'dart:developer' as developer;
// import '../../../core/services/socket_service.dart';
// import '../../service/table_order_service.dart';
// import '../../../core/utils/snakbar_utils.dart';
// import '../../../data/models/RequestModel/create_order_request.dart';
// import '../../../data/models/ResponseModel/table_model.dart';
// import '../../../data/repositories/order_repository.dart';
// import '../../../route/app_routes.dart';
// import '../../model/table_order_state_mode.dart';
// import '../../view/WaiterPanel/TakeOrder/widgets/notifications_widget.dart';
//
// /// Main controller for order management with socket integration
// class OrderManagementController extends GetxController {
//   // Dependencies
//   final OrderRepository _orderRepository = OrderRepository();
//   final SocketService _socketService = SocketService.instance;
//
//   // State
//   final tableOrders = <int, TableOrderState>{}.obs;
//   final activeTableId = Rxn<int>();
//   final formKey = GlobalKey<FormState>();
//   final isLoading = false.obs;
//   final isSocketConnected = false.obs;
//
//   // Helpers
//   late final _socketHandler = _SocketHandler(this);
//   late final _stateManager = _StateManager(this);
//   late final _itemManager = _ItemManager(this);
//   late final _orderProcessor = _OrderProcessor(this);
//   late final _uiHelper = _UIHelper(this);
//
//   @override
//   void onInit() {
//     super.onInit();
//     developer.log('OrderManagementController initialized', name: 'ORDER_MGMT');
//     _socketHandler.initialize();
//   }
//
//   @override
//   void onClose() {
//     _socketHandler.cleanup();
//     tableOrders.values.forEach((state) => state.dispose());
//     tableOrders.clear();
//     super.onClose();
//   }
//
//   // Delegate to helpers
//   TableOrderState getTableState(int tableId) => _stateManager.getTableState(tableId);
//   void setActiveTable(int tableId, dynamic tableInfoData) => _stateManager.setActiveTable(tableId, tableInfoData);
//   void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) => _stateManager.resetTableStateIfNeeded(tableId, tableInfo);
//   void clearTableOrders(int tableId) => _stateManager.clearTableOrders(tableId);
//
//   void addItemToTable(int tableId, Map<String, dynamic> item) => _itemManager.addItemToTable(tableId, item);
//   void incrementItemQuantity(int tableId, int index) => _itemManager.incrementItemQuantity(tableId, index);
//   void decrementItemQuantity(int tableId, int index, BuildContext context) => _itemManager.decrementItemQuantity(tableId, index, context);
//   void removeItemFromTable(int tableId, int index, BuildContext context) => _itemManager.removeItemFromTable(tableId, index, context);
//
//   Future<void> fetchOrder(int orderId, int tableId) => _orderProcessor.fetchOrder(orderId, tableId);
//   Future<void> proceedToCheckout(int tableId, BuildContext context, dynamic tableInfoData, List<Map<String, dynamic>> orderItems) => _orderProcessor.proceedToCheckout(tableId, context, tableInfoData, orderItems);
//
//   void toggleUrgentForTable(int tableId, BuildContext context, dynamic tableInfoData) => _uiHelper.toggleUrgentForTable(tableId, context, tableInfoData);
//   void navigateToAddItems(int tableId, dynamic tableInfoData) => _uiHelper.navigateToAddItems(tableId, tableInfoData);
//   bool canProceedToCheckout(int tableId) => _uiHelper.canProceedToCheckout(tableId);
//
//   bool get socketConnected => isSocketConnected.value;
//   Future<void> reconnectSocket() => _socketHandler.reconnect();
//
//   // Public utility methods for external use
//   Map<String, dynamic>? tableInfoToMap(TableInfo? tableInfo) => _uiHelper.tableInfoToMap(tableInfo);
//   TableInfo? mapToTableInfo(Map<String, dynamic>? map) => _stateManager.mapToTableInfo(map);
// }
//
// // ==================== SOCKET HANDLER ====================
// class _SocketHandler {
//   final OrderManagementController _controller;
//   _SocketHandler(this._controller);
//
//   void initialize() {
//     try {
//       developer.log('🔌 Setting up socket listeners...', name: 'SOCKET');
//
//       _controller.isSocketConnected.value = _controller._socketService.isConnected;
//
//       _controller._orderRepository.initializeSocketListeners(
//         onNewOrder: _handleNewOrder,
//         onOrderStatusUpdate: _handleOrderStatusUpdate,
//         onPaymentUpdate: _handlePaymentUpdate,
//       );
//
//       _controller._socketService.on('authenticated', (data) {
//         _controller.isSocketConnected.value = true;
//         developer.log('✅ Socket authenticated', name: 'SOCKET');
//       });
//
//       _controller._socketService.on('disconnect', (data) {
//         _controller.isSocketConnected.value = false;
//         developer.log('⚠️ Socket disconnected', name: 'SOCKET');
//       });
//
//       developer.log('✅ Socket listeners initialized', name: 'SOCKET');
//     } catch (e) {
//       developer.log('❌ Socket initialization error: $e', name: 'SOCKET');
//     }
//   }
//
//   void cleanup() {
//     developer.log('🔌 Removing socket listeners...', name: 'SOCKET');
//     _controller._orderRepository.removeSocketListeners();
//     _controller._socketService.off('authenticated');
//     _controller._socketService.off('disconnect');
//   }
//
//   Future<void> reconnect() async {
//     if (!_controller._socketService.isConnected) {
//       developer.log('🔄 Reconnecting socket...', name: 'SOCKET');
//       _controller._socketService.reconnect();
//     } else {
//       developer.log('✅ Socket already connected', name: 'SOCKET');
//     }
//   }
//
//   void _handleNewOrder(Map<String, dynamic> data) {
//     try {
//       final orderData = _extractOrderData(data);
//       if (orderData == null) return;
//
//       final orderId = _extractOrderId(orderData);
//       final tableNumber = orderData['table_number'] ?? orderData['tableNumber'] ?? 'Unknown';
//       final message = data['message'] ?? 'New order received for Table $tableNumber';
//
//       developer.log('📋 New order - ID: $orderId, Table: $tableNumber', name: 'SOCKET');
//
//       _showNotification(message, '🔔 New Order - Table $tableNumber', isSuccess: true);
//       _refreshTables();
//     } catch (e) {
//       developer.log('❌ Error handling new order: $e', name: 'SOCKET');
//     }
//   }
//
//   void _handleOrderStatusUpdate(Map<String, dynamic> data) {
//     try {
//       final orderData = _extractOrderData(data);
//       if (orderData == null) return;
//
//       final orderId = _extractOrderId(orderData);
//       final newStatus = orderData['status'] ?? 'unknown';
//       final message = data['message'] ?? 'Order #$orderId status: $newStatus';
//
//       developer.log('📋 Status update - Order: $orderId, Status: $newStatus', name: 'SOCKET');
//
//       _updateOrderStatusInTables(orderId, newStatus);
//       _showNotification(message, '📊 Order Status Update', isSuccess: false);
//       _refreshTables();
//     } catch (e) {
//       developer.log('❌ Error handling status update: $e', name: 'SOCKET');
//     }
//   }
//
//   void _handlePaymentUpdate(Map<String, dynamic> data) {
//     try {
//       final message = data['message'] ?? 'Payment updated';
//       final orderData = _extractOrderData(data);
//       final orderId = orderData != null ? _extractOrderId(orderData) : 0;
//
//       developer.log('📋 Payment update - Order: $orderId', name: 'SOCKET');
//
//       _showNotification(message, '💰 Payment Received', isSuccess: true);
//       _refreshTables();
//     } catch (e) {
//       developer.log('❌ Error handling payment update: $e', name: 'SOCKET');
//     }
//   }
//
//   Map<String, dynamic>? _extractOrderData(Map<String, dynamic> data) {
//     final orderData = data.containsKey('data') ? data['data'] as Map<String, dynamic>? : data;
//     if (orderData == null || orderData.isEmpty) {
//       developer.log('⚠️ Empty order data', name: 'SOCKET');
//       return null;
//     }
//     return orderData;
//   }
//
//   int _extractOrderId(Map<String, dynamic> orderData) {
//     return orderData['orderId'] ?? orderData['order_id'] ?? orderData['id'] ?? 0;
//   }
//
//   void _updateOrderStatusInTables(int orderId, String newStatus) {
//     for (var state in _controller.tableOrders.values) {
//       if (state.placedOrderId.value == orderId) {
//         developer.log('📝 Updating status for table ${state.tableId}: $newStatus', name: 'SOCKET');
//       }
//     }
//   }
//
//   void _showNotification(String message, String title, {required bool isSuccess}) {
//     if (Get.context != null) {
//       if (isSuccess) {
//         SnackBarUtil.showSuccess(Get.context!, message, title: title, duration: const Duration(seconds: 2));
//       } else {
//         SnackBarUtil.show(Get.context!, message, title: title, type: SnackBarType.info, duration: const Duration(seconds: 2));
//       }
//     }
//   }
//
//   void _refreshTables() {
//     try {
//       Get.find<TakeOrdersController>().refreshTables();
//       developer.log('✅ Tables refreshed', name: 'SOCKET');
//     } catch (e) {
//       developer.log('⚠️ Could not refresh tables: $e', name: 'SOCKET');
//     }
//   }
// }
//
// // ==================== STATE MANAGER ====================
// class _StateManager {
//   final OrderManagementController _controller;
//   _StateManager(this._controller);
//
//   TableOrderState getTableState(int tableId) {
//     final state = _controller.tableOrders.putIfAbsent(
//       tableId,
//           () => TableOrderState(tableId: tableId),
//     );
//     developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}", name: "STATE");
//     return state;
//   }
//
//   void setActiveTable(int tableId, dynamic tableInfoData) {
//     final tableInfo = _parseTableInfo(tableInfoData);
//     _controller.activeTableId.value = tableId;
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//
//     developer.log('Active table: $tableId, Order: $orderId', name: 'STATE');
//
//     if (orderId > 0 && !state.hasLoadedOrder.value) {
//       _controller.fetchOrder(orderId, tableId);
//     } else if (orderId <= 0 && state.placedOrderId.value != null && state.placedOrderId.value! > 0 && !state.hasLoadedOrder.value) {
//       _controller.fetchOrder(state.placedOrderId.value!, tableId);
//     }
//   }
//
//   void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) {
//     final state = getTableState(tableId);
//     final orderId = tableInfo?.currentOrder?.orderId ?? 0;
//     final status = tableInfo?.table.status ?? 'unknown';
//
//     if (orderId <= 0 && status.toLowerCase() == 'available' && state.hasLoadedOrder.value) {
//       developer.log("Resetting state for table $tableId", name: "STATE");
//       state.clear();
//       state.hasLoadedOrder.value = false;
//     }
//   }
//
//   void clearTableOrders(int tableId) {
//     if (_controller.tableOrders.containsKey(tableId)) {
//       _controller.tableOrders[tableId]?.dispose();
//       _controller.tableOrders.remove(tableId);
//     }
//   }
//
//   TableInfo? _parseTableInfo(dynamic tableInfoData) {
//     if (tableInfoData is TableInfo) return tableInfoData;
//     if (tableInfoData is Map<String, dynamic>) return mapToTableInfo(tableInfoData);
//     return null;
//   }
//
//   // Public method for external use
//   TableInfo? mapToTableInfo(Map<String, dynamic>? map) {
//     if (map == null) return null;
//     try {
//       return TableInfo(
//         table: Table(
//           id: map['id'] as int,
//           hotelOwnerId: map['hotelOwnerId'] as int,
//           tableAreaId: map['tableAreaId'] as int,
//           tableNumber: map['tableNumber'] as String,
//           tableType: map['tableType'] as String,
//           capacity: map['capacity'] as int,
//           status: map['status'] as String,
//           description: map['description'] as String?,
//           location: map['location'] as String?,
//           createdAt: map['createdAt'] as String,
//           updatedAt: map['updatedAt'] as String,
//         ),
//         currentOrder: map['currentOrder'] != null
//             ? CurrentOrder.fromJson(map['currentOrder'] as Map<String, dynamic>)
//             : null,
//         areaName: map['areaName'] as String,
//       );
//     } catch (e) {
//       developer.log('Error converting map to TableInfo: $e', name: 'STATE');
//       return null;
//     }
//   }
// }
//
// // ==================== ITEM MANAGER ====================
// class _ItemManager {
//   final OrderManagementController _controller;
//   _ItemManager(this._controller);
//
//   void addItemToTable(int tableId, Map<String, dynamic> item) {
//     final state = _controller.getTableState(tableId);
//     TableOrderService.mergeOrAddItem(state.orderItems, item);
//     _updateTotal(state);
//   }
//
//   void incrementItemQuantity(int tableId, int index) {
//     final state = _controller.getTableState(tableId);
//     if (!_isValidIndex(index, state.orderItems.length)) return;
//
//     final item = state.orderItems[index];
//     final newQty = (item['quantity'] as int) + 1;
//
//     state.orderItems[index] = TableOrderService.updateItemQuantity(item, newQty);
//     _updateTotal(state);
//     _logTableSnapshot(tableId, state);
//   }
//
//   void decrementItemQuantity(int tableId, int index, BuildContext context) {
//     final state = _controller.getTableState(tableId);
//     if (!_isValidIndex(index, state.orderItems.length)) return;
//
//     final item = state.orderItems[index];
//     final currentQty = item['quantity'] as int;
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     if (frozenQty == 0) {
//       if (currentQty > 1) {
//         state.orderItems[index] = TableOrderService.updateItemQuantity(item, currentQty - 1);
//         _updateTotal(state);
//       } else {
//         _removeItem(state, index, context);
//       }
//     } else {
//       if (TableOrderService.canDecrementItem(currentQty, frozenQty)) {
//         state.orderItems[index] = TableOrderService.updateItemQuantity(item, currentQty - 1);
//         _updateTotal(state);
//       } else {
//         _showWarning(context, 'Cannot reduce below sent quantity ($frozenQty)', 'Item Already Sent');
//       }
//     }
//     _logTableSnapshot(tableId, state);
//   }
//
//   void removeItemFromTable(int tableId, int index, BuildContext context) {
//     final state = _controller.getTableState(tableId);
//     if (!_isValidIndex(index, state.orderItems.length)) return;
//
//     final item = state.orderItems[index];
//     final frozenQty = state.getFrozenQuantity(item['id'].toString());
//
//     if (!TableOrderService.canRemoveItem(frozenQty)) {
//       _showWarning(context, 'Cannot remove - $frozenQty already sent to kitchen', 'Item Already Sent');
//       return;
//     }
//
//     _removeItem(state, index, context);
//     _logTableSnapshot(tableId, state);
//   }
//
//   void _updateTotal(TableOrderState state) {
//     final newTotal = TableOrderService.calculateTotal(state.orderItems);
//     state.updateTotal(newTotal);
//   }
//
//   void _removeItem(TableOrderState state, int index, BuildContext context) {
//     final removedItem = state.orderItems.removeAt(index);
//     _updateTotal(state);
//     SnackBarUtil.showInfo(context, '${removedItem['item_name']} removed', title: 'Removed', duration: const Duration(seconds: 1));
//   }
//
//   bool _isValidIndex(int index, int length) {
//     if (index < 0 || index >= length) {
//       developer.log('❌ Invalid index $index', name: 'ITEM_MGMT');
//       return false;
//     }
//     return true;
//   }
//
//   void _showWarning(BuildContext context, String message, String title) {
//     SnackBarUtil.showWarning(context, message, title: title, duration: const Duration(seconds: 2));
//   }
//
//   void _logTableSnapshot(int tableId, TableOrderState state) {
//     final buffer = StringBuffer('TABLE $tableId:\n');
//     for (var i = 0; i < state.orderItems.length; i++) {
//       final it = state.orderItems[i];
//       final frozen = state.getFrozenQuantity(it['id'].toString());
//       buffer.writeln('[$i] ${it['item_name']} qty:${it['quantity']} frozen:$frozen');
//     }
//     buffer.writeln('Total: ${state.finalCheckoutTotal.value}');
//     developer.log(buffer.toString(), name: 'ITEM_MGMT');
//   }
// }
//
// // ==================== ORDER PROCESSOR ====================
// class _OrderProcessor {
//   final OrderManagementController _controller;
//   _OrderProcessor(this._controller);
//
//   Future<void> fetchOrder(int orderId, int tableId) async {
//     final state = _controller.getTableState(tableId);
//     if (state.isLoadingOrder.value || orderId == 0 || state.hasLoadedOrder.value) return;
//
//     try {
//       state.isLoadingOrder.value = true;
//       final orderData = await _controller._orderRepository.getOrderById(orderId);
//
//       state.placedOrderId.value = orderData.data.order.id;
//       state.orderItems.clear();
//       state.frozenItems.clear();
//
//       final processedItems = TableOrderService.processOrderItems(orderData.data.items, state.frozenItems);
//       state.orderItems.addAll(processedItems);
//
//       _controller._itemManager._updateTotal(state);
//       developer.log('Order fetched: ${state.orderItems.length} items', name: 'ORDER_API');
//     } catch (e) {
//       developer.log('Error fetching order: $e', name: 'ORDER_API');
//     } finally {
//       state.isLoadingOrder.value = false;
//       state.hasLoadedOrder.value = true;
//     }
//   }
//
//   Future<void> proceedToCheckout(int tableId, BuildContext context, dynamic tableInfoData, List<Map<String, dynamic>> orderItems) async {
//     final tableInfo = _controller._stateManager._parseTableInfo(tableInfoData);
//     await _processOrder(tableId, context, tableInfo, orderItems, 'KOT sent to manager');
//   }
//
//   Future<void> _processOrder(int tableId, BuildContext context, TableInfo? tableInfo, List<Map<String, dynamic>> orderItems, String successMessage) async {
//     try {
//       _controller.isLoading.value = true;
//       final state = _controller.getTableState(tableId);
//       final newItems = TableOrderService.getNewItems(state.frozenItems, orderItems);
//
//       if (newItems.isEmpty) {
//         SnackBarUtil.showWarning(context, 'No new items to send', title: 'Warning', duration: const Duration(seconds: 2));
//         return;
//       }
//
//       if (state.isReorderScenario) {
//         await _addItemsToExistingOrder(state.placedOrderId.value!, tableId, context, tableInfo, newItems);
//       } else {
//         await _createNewOrder(tableId, context, tableInfo, state, newItems, successMessage);
//       }
//     } catch (e) {
//       developer.log('Order error: $e', name: 'ORDER_API');
//       SnackBarUtil.showError(context, 'Failed to place order', title: 'Error');
//     } finally {
//       _controller.isLoading.value = false;
//     }
//   }
//
//   Future<void> _createNewOrder(int tableId, BuildContext context, TableInfo? tableInfo, TableOrderState state, List<Map<String, dynamic>> newItems, String successMessage) async {
//     final request = CreateOrderRequest(
//       orderData: OrderData(
//         hotelTableId: tableInfo?.table.id ?? tableId,
//         customerName: state.fullNameController.text.trim(),
//         customerPhone: state.phoneController.text.trim(),
//         tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//         status: 'pending',
//       ),
//       items: newItems.map((item) => OrderItemRequest(
//         menuItemId: item['id'] as int,
//         quantity: item['quantity'] as int,
//         specialInstructions: item['special_instructions'] as String?,
//       )).toList(),
//     );
//
//     final response = await _controller._orderRepository.createOrder(request);
//     final orderId = response.data.order.id;
//     state.placedOrderId.value = orderId;
//     state.addFrozenItems(newItems);
//
//     await showOrderNotification(
//       orderId: orderId,
//       tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//       itemCount: newItems.length,
//       isNewOrder: true,
//     );
//
//     _showSuccessAndRefresh(context, tableInfo, tableId, successMessage);
//   }
//
//   Future<void> _addItemsToExistingOrder(int orderId, int tableId, BuildContext context, TableInfo? tableInfo, List<Map<String, dynamic>> newItems) async {
//     await _controller._orderRepository.addItemsToOrder(orderId, newItems);
//
//     final state = _controller.getTableState(tableId);
//     state.addFrozenItems(newItems);
//
//     await showOrderNotification(
//       orderId: orderId,
//       tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
//       itemCount: newItems.length,
//       isNewOrder: false,
//     );
//
//     _showSuccessAndRefresh(context, tableInfo, tableId, 'Items added to existing order');
//   }
//
//   void _showSuccessAndRefresh(BuildContext context, TableInfo? tableInfo, int tableId, String message) {
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//     SnackBarUtil.showSuccess(context, '$message for Table $tableNumber', title: 'Success', duration: const Duration(seconds: 2));
//
//     _controller.getTableState(tableId).hasLoadedOrder.value = false;
//     Get.find<TakeOrdersController>().refreshTables();
//     NavigationService.goBack();
//   }
// }
//
// // ==================== UI HELPER ====================
// class _UIHelper {
//   final OrderManagementController _controller;
//   _UIHelper(this._controller);
//
//   void toggleUrgentForTable(int tableId, BuildContext context, dynamic tableInfoData) {
//     final tableInfo = _controller._stateManager._parseTableInfo(tableInfoData);
//     final state = _controller.getTableState(tableId);
//     state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;
//
//     final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
//     final message = state.isMarkAsUrgent.value ? 'Table $tableNumber marked as urgent' : 'Table $tableNumber removed from urgent';
//
//     SnackBarUtil.show(context, message,
//         title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
//         type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
//         duration: const Duration(seconds: 1));
//   }
//
//   void navigateToAddItems(int tableId, dynamic tableInfoData) {
//     try {
//       final tableMap = tableInfoData is TableInfo ? tableInfoToMap(tableInfoData) : (tableInfoData as Map<String, dynamic>?);
//       NavigationService.addItems(tableMap);
//     } catch (e) {
//       developer.log('Navigation error: $e', name: 'UI');
//       SnackBarUtil.showError(Get.context!, 'Unable to proceed', title: 'Error');
//     }
//   }
//
//   bool canProceedToCheckout(int tableId) {
//     return _controller.getTableState(tableId).isAvailableForNewOrder;
//   }
//
//   // Public method for external use
//   Map<String, dynamic>? tableInfoToMap(TableInfo? tableInfo) {
//     if (tableInfo == null) return null;
//     return {
//       'id': tableInfo.table.id,
//       'tableNumber': tableInfo.table.tableNumber,
//       'tableType': tableInfo.table.tableType,
//       'capacity': tableInfo.table.capacity,
//       'status': tableInfo.table.status,
//       'description': tableInfo.table.description,
//       'location': tableInfo.table.location,
//       'areaName': tableInfo.areaName,
//       'hotelOwnerId': tableInfo.table.hotelOwnerId,
//       'tableAreaId': tableInfo.table.tableAreaId,
//       'createdAt': tableInfo.table.createdAt,
//       'updatedAt': tableInfo.table.updatedAt,
//       'currentOrder': tableInfo.currentOrder?.toJson(),
//     };
//   }
// }
//
//

import 'package:flutter/material.dart' hide Table;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hotelbilling/app/modules/controllers/WaiterPanelController/take_order_controller.dart';
import 'dart:developer' as developer;
import '../../../core/services/socket_service.dart';
import '../../service/table_order_service.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/RequestModel/create_order_request.dart';
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../route/app_routes.dart';
import '../../model/table_order_state_mode.dart';
import '../../widgets/notifications_widget.dart';

/// Main controller for order management with socket integration
class OrderManagementController extends GetxController {
  // Dependencies
  final OrderRepository _orderRepository = OrderRepository();
  final SocketService _socketService = SocketService.instance;

  // State
  final tableOrders = <int, TableOrderState>{}.obs;
  final activeTableId = Rxn<int>();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isSocketConnected = false.obs;

  // 🆕 Navigation flag to prevent unnecessary fetching
  final isComingFromAddItems = false.obs;

  // Helpers
  late final _socketHandler = _SocketHandler(this);
  late final _stateManager = _StateManager(this);
  late final _itemManager = _ItemManager(this);
  late final _orderProcessor = _OrderProcessor(this);
  late final _uiHelper = _UIHelper(this);

  @override
  void onInit() {
    super.onInit();
    developer.log('OrderManagementController initialized', name: 'ORDER_MGMT');
    _socketHandler.initialize();
  }

  @override
  void onClose() {
    _socketHandler.cleanup();
    tableOrders.values.forEach((state) => state.dispose());
    tableOrders.clear();
    super.onClose();
  }

  // Delegate to helpers
  TableOrderState getTableState(int tableId) => _stateManager.getTableState(tableId);
  void setActiveTable(int tableId, dynamic tableInfoData) => _stateManager.setActiveTable(tableId, tableInfoData);
  void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) => _stateManager.resetTableStateIfNeeded(tableId, tableInfo);
  void clearTableOrders(int tableId) => _stateManager.clearTableOrders(tableId);

  void addItemToTable(int tableId, Map<String, dynamic> item) => _itemManager.addItemToTable(tableId, item);
  void incrementItemQuantity(int tableId, int index) => _itemManager.incrementItemQuantity(tableId, index);
  void decrementItemQuantity(int tableId, int index, BuildContext context) => _itemManager.decrementItemQuantity(tableId, index, context);
  void removeItemFromTable(int tableId, int index, BuildContext context) => _itemManager.removeItemFromTable(tableId, index, context);

  Future<void> fetchOrder(int orderId, int tableId) => _orderProcessor.fetchOrder(orderId, tableId);
  Future<void> proceedToCheckout(int tableId, BuildContext context, dynamic tableInfoData, List<Map<String, dynamic>> orderItems) => _orderProcessor.proceedToCheckout(tableId, context, tableInfoData, orderItems);

  void toggleUrgentForTable(int tableId, BuildContext context, dynamic tableInfoData) => _uiHelper.toggleUrgentForTable(tableId, context, tableInfoData);
  void navigateToAddItems(int tableId, dynamic tableInfoData) => _uiHelper.navigateToAddItems(tableId, tableInfoData);
  bool canProceedToCheckout(int tableId) => _uiHelper.canProceedToCheckout(tableId);

  Future<void> updateCustomerInfo(int orderId, String name, String phone) =>
      _orderProcessor.updateCustomerInfo(orderId, name, phone);

  bool get socketConnected => isSocketConnected.value;
  Future<void> reconnectSocket() => _socketHandler.reconnect();

  // 🆕 Navigation flag management
  void setComingFromAddItems(bool value) {
    isComingFromAddItems.value = value;
    developer.log('🚩 Navigation flag set: isComingFromAddItems = $value', name: 'NAVIGATION');
  }

  void resetNavigationFlag() {
    isComingFromAddItems.value = false;
    developer.log('🔄 Navigation flag reset', name: 'NAVIGATION');
  }

  // Public utility methods for external use
  Map<String, dynamic>? tableInfoToMap(TableInfo? tableInfo) => _uiHelper.tableInfoToMap(tableInfo);
  TableInfo? mapToTableInfo(Map<String, dynamic>? map) => _stateManager.mapToTableInfo(map);
}

// ==================== SOCKET HANDLER ====================
class _SocketHandler {
  final OrderManagementController _controller;
  _SocketHandler(this._controller);

  void initialize() {
    try {
      developer.log('🔌 Setting up socket listeners...', name: 'SOCKET');

      _controller.isSocketConnected.value = _controller._socketService.isConnected;

      _controller._orderRepository.initializeSocketListeners(
        onNewOrder: _handleNewOrder,
        onOrderStatusUpdate: _handleOrderStatusUpdate,
        onPaymentUpdate: _handlePaymentUpdate,
      );

      _controller._socketService.on('authenticated', (data) {
        _controller.isSocketConnected.value = true;
        developer.log('✅ Socket authenticated', name: 'SOCKET');
      });

      _controller._socketService.on('disconnect', (data) {
        _controller.isSocketConnected.value = false;
        developer.log('⚠️ Socket disconnected', name: 'SOCKET');
      });

      developer.log('✅ Socket listeners initialized', name: 'SOCKET');
    } catch (e) {
      developer.log('❌ Socket initialization error: $e', name: 'SOCKET');
    }
  }

  void cleanup() {
    developer.log('🔌 Removing socket listeners...', name: 'SOCKET');
    _controller._orderRepository.removeSocketListeners();
    _controller._socketService.off('authenticated');
    _controller._socketService.off('disconnect');
  }

  Future<void> reconnect() async {
    if (!_controller._socketService.isConnected) {
      developer.log('🔄 Reconnecting socket...', name: 'SOCKET');
      _controller._socketService.reconnect();
    } else {
      developer.log('✅ Socket already connected', name: 'SOCKET');
    }
  }

  void _handleNewOrder(Map<String, dynamic> data) {
    try {
      final orderData = _extractOrderData(data);
      if (orderData == null) return;

      final orderId = _extractOrderId(orderData);
      final tableNumber = orderData['table_number'] ?? orderData['tableNumber'] ?? 'Unknown';
      final message = data['message'] ?? 'New order received for Table $tableNumber';

      developer.log('📋 New order - ID: $orderId, Table: $tableNumber', name: 'SOCKET');

      _showNotification(message, '🔔 New Order - Table $tableNumber', isSuccess: true);
      _refreshTables();
    } catch (e) {
      developer.log('❌ Error handling new order: $e', name: 'SOCKET');
    }
  }

  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    try {
      final orderData = _extractOrderData(data);
      if (orderData == null) return;

      final orderId = _extractOrderId(orderData);
      final newStatus = orderData['status'] ?? 'unknown';
      final message = data['message'] ?? 'Order #$orderId status: $newStatus';

      developer.log('📋 Status update - Order: $orderId, Status: $newStatus', name: 'SOCKET');

      _updateOrderStatusInTables(orderId, newStatus);
      _showNotification(message, '📊 Order Status Update', isSuccess: false);
      _refreshTables();
    } catch (e) {
      developer.log('❌ Error handling status update: $e', name: 'SOCKET');
    }
  }

  void _handlePaymentUpdate(Map<String, dynamic> data) {
    try {
      final message = data['message'] ?? 'Payment updated';
      final orderData = _extractOrderData(data);
      final orderId = orderData != null ? _extractOrderId(orderData) : 0;

      developer.log('📋 Payment update - Order: $orderId', name: 'SOCKET');

      _showNotification(message, '💰 Payment Received', isSuccess: true);
      _refreshTables();
    } catch (e) {
      developer.log('❌ Error handling payment update: $e', name: 'SOCKET');
    }
  }

  Map<String, dynamic>? _extractOrderData(Map<String, dynamic> data) {
    final orderData = data.containsKey('data') ? data['data'] as Map<String, dynamic>? : data;
    if (orderData == null || orderData.isEmpty) {
      developer.log('⚠️ Empty order data', name: 'SOCKET');
      return null;
    }
    return orderData;
  }

  int _extractOrderId(Map<String, dynamic> orderData) {
    return orderData['orderId'] ?? orderData['order_id'] ?? orderData['id'] ?? 0;
  }

  void _updateOrderStatusInTables(int orderId, String newStatus) {
    for (var state in _controller.tableOrders.values) {
      if (state.placedOrderId.value == orderId) {
        developer.log('📝 Updating status for table ${state.tableId}: $newStatus', name: 'SOCKET');
      }
    }
  }

  void _showNotification(String message, String title, {required bool isSuccess}) {
    if (Get.context != null) {
      if (isSuccess) {
        SnackBarUtil.showSuccess(Get.context!, message, title: title, duration: const Duration(seconds: 2));
      } else {
        SnackBarUtil.show(Get.context!, message, title: title, type: SnackBarType.info, duration: const Duration(seconds: 2));
      }
    }
  }

  void _refreshTables() {
    try {
      Get.find<TakeOrdersController>().refreshTables();
      developer.log('✅ Tables refreshed', name: 'SOCKET');
    } catch (e) {
      developer.log('⚠️ Could not refresh tables: $e', name: 'SOCKET');
    }
  }
}

// ==================== STATE MANAGER ====================
class _StateManager {
  final OrderManagementController _controller;
  _StateManager(this._controller);

  TableOrderState getTableState(int tableId) {
    final state = _controller.tableOrders.putIfAbsent(
      tableId, () => TableOrderState(tableId: tableId),
    );
    developer.log("Table loaded ($tableId). Items: ${state.orderItems.length}", name: "STATE");
    return state;
  }

  void setActiveTable(int tableId, dynamic tableInfoData) {
    final tableInfo = _parseTableInfo(tableInfoData);
    _controller.activeTableId.value = tableId;
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;
    final tableStatus = tableInfo?.table.status ?? 'unknown';

    developer.log('Active table: $tableId, Order: $orderId, Status: $tableStatus', name: 'STATE');

    // 🆕 Check navigation flag before fetching
    if (_controller.isComingFromAddItems.value) {
      developer.log('⏭️ Skipping fetch - coming from Add Items', name: 'STATE');
      return;
    }

    // ✅ CRITICAL FIX: Reset state if table is available and has no current order
    if (orderId <= 0 && tableStatus.toLowerCase() == 'available') {
      developer.log('🧹 Table is available with no order - clearing stale state', name: 'STATE');
      state.clear();
      state.hasLoadedOrder.value = false;
      return; // Don't fetch anything
    }

    // Fetch order logic - only when there's an actual order
    if (orderId > 0) {
      developer.log('📥 Fetching order: $orderId for table: $tableId', name: 'STATE');
      _controller.fetchOrder(orderId, tableId);
    }
  }
  void resetTableStateIfNeeded(int tableId, TableInfo? tableInfo) {
    final state = getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;
    final status = tableInfo?.table.status ?? 'unknown';

    if (orderId <= 0 && status.toLowerCase() == 'available' && state.hasLoadedOrder.value) {
      developer.log("Resetting state for table $tableId", name: "STATE");
      state.clear();
      state.hasLoadedOrder.value = false;
    }
  }

  void clearTableOrders(int tableId) {
    if (_controller.tableOrders.containsKey(tableId)) {
      _controller.tableOrders[tableId]?.dispose();
      _controller.tableOrders.remove(tableId);
    }
  }

  TableInfo? _parseTableInfo(dynamic tableInfoData) {
    if (tableInfoData is TableInfo) return tableInfoData;
    if (tableInfoData is Map<String, dynamic>) return mapToTableInfo(tableInfoData);
    return null;
  }

  // Public method for external use
  TableInfo? mapToTableInfo(Map<String, dynamic>? map) {
    if (map == null) return null;
    try {
      return TableInfo(
        table: Table(
          id: map['id'] as int,
          hotelOwnerId: map['hotelOwnerId'] as int,
          tableAreaId: map['tableAreaId'] as int,
          tableNumber: map['tableNumber'] as String,
          tableType: map['tableType'] as String,
          capacity: map['capacity'] as int,
          status: map['status'] as String,
          description: map['description'] as String?,
          location: map['location'] as String?,
          createdAt: map['createdAt'] as String,
          updatedAt: map['updatedAt'] as String,
        ),
        currentOrder: map['currentOrder'] != null
            ? CurrentOrder.fromJson(map['currentOrder'] as Map<String, dynamic>)
            : null,
        areaName: map['areaName'] as String,
      );
    } catch (e) {
      developer.log('Error converting map to TableInfo: $e', name: 'STATE');
      return null;
    }
  }
}

// ==================== ITEM MANAGER ====================
class _ItemManager {
  final OrderManagementController _controller;
  _ItemManager(this._controller);

  void addItemToTable(int tableId, Map<String, dynamic> item) {
    final state = _controller.getTableState(tableId);
    TableOrderService.mergeOrAddItem(state.orderItems, item);
    _updateTotal(state);
  }

  void incrementItemQuantity(int tableId, int index) {
    final state = _controller.getTableState(tableId);
    if (!_isValidIndex(index, state.orderItems.length)) return;

    final item = state.orderItems[index];
    final newQty = (item['quantity'] as int) + 1;

    state.orderItems[index] = TableOrderService.updateItemQuantity(item, newQty);
    _updateTotal(state);
    _logTableSnapshot(tableId, state);
  }

  void decrementItemQuantity(int tableId, int index, BuildContext context) {
    final state = _controller.getTableState(tableId);
    if (!_isValidIndex(index, state.orderItems.length)) return;

    final item = state.orderItems[index];
    final currentQty = item['quantity'] as int;
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    if (frozenQty == 0) {
      if (currentQty > 1) {
        state.orderItems[index] = TableOrderService.updateItemQuantity(item, currentQty - 1);
        _updateTotal(state);
      } else {
        _removeItem(state, index, context);
      }
    } else {
      if (TableOrderService.canDecrementItem(currentQty, frozenQty)) {
        state.orderItems[index] = TableOrderService.updateItemQuantity(item, currentQty - 1);
        _updateTotal(state);
      } else {
        _showWarning(context, 'Cannot reduce below sent quantity ($frozenQty)', 'Item Already Sent');
      }
    }
    _logTableSnapshot(tableId, state);
  }

  void removeItemFromTable(int tableId, int index, BuildContext context) {
    final state = _controller.getTableState(tableId);
    if (!_isValidIndex(index, state.orderItems.length)) return;

    final item = state.orderItems[index];
    final frozenQty = state.getFrozenQuantity(item['id'].toString());

    if (!TableOrderService.canRemoveItem(frozenQty)) {
      _showWarning(context, 'Cannot remove - $frozenQty already sent to kitchen', 'Item Already Sent');
      return;
    }

    _removeItem(state, index, context);
    _logTableSnapshot(tableId, state);
  }

  void _updateTotal(TableOrderState state) {
    final newTotal = TableOrderService.calculateTotal(state.orderItems);
    state.updateTotal(newTotal);
  }

  void _removeItem(TableOrderState state, int index, BuildContext context) {
    final removedItem = state.orderItems.removeAt(index);
    _updateTotal(state);
    SnackBarUtil.showInfo(context, '${removedItem['item_name']} removed', title: 'Removed', duration: const Duration(seconds: 1));
  }

  bool _isValidIndex(int index, int length) {
    if (index < 0 || index >= length) {
      developer.log('❌ Invalid index $index', name: 'ITEM_MGMT');
      return false;
    }
    return true;
  }

  void _showWarning(BuildContext context, String message, String title) {
    SnackBarUtil.showWarning(context, message, title: title, duration: const Duration(seconds: 2));
  }

  void _logTableSnapshot(int tableId, TableOrderState state) {
    final buffer = StringBuffer('TABLE $tableId:\n');
    for (var i = 0; i < state.orderItems.length; i++) {
      final it = state.orderItems[i];
      final frozen = state.getFrozenQuantity(it['id'].toString());
      buffer.writeln('[$i] ${it['item_name']} qty:${it['quantity']} frozen:$frozen');
    }
    buffer.writeln('Total: ${state.finalCheckoutTotal.value}');
    developer.log(buffer.toString(), name: 'ITEM_MGMT');
  }
}

// ==================== ORDER PROCESSOR ====================
class _OrderProcessor {
  final OrderManagementController _controller;
  _OrderProcessor(this._controller);

  Future<void> fetchOrder(int orderId, int tableId) async {
    final state = _controller.getTableState(tableId);
    if (state.isLoadingOrder.value || orderId == 0) return;

    try {
      state.isLoadingOrder.value = true;
      final orderData = await _controller._orderRepository.getOrderById(orderId);

      state.placedOrderId.value = orderData.data.order.id;
      state.orderItems.clear();
      state.frozenItems.clear();

      final processedItems = TableOrderService.processOrderItems(orderData.data.items, state.frozenItems);
      state.orderItems.addAll(processedItems);

      _controller._itemManager._updateTotal(state);
      state.hasLoadedOrder.value = true;
      developer.log('✅ Order fetched: ${state.orderItems.length} items', name: 'ORDER_API');
    } catch (e) {
      developer.log('❌ Error fetching order: $e', name: 'ORDER_API');
    } finally {
      state.isLoadingOrder.value = false;
    }
  }

  /// Modified proceedToCheckout to handle customer info updates
  Future<void> proceedToCheckout(int tableId, BuildContext context, dynamic tableInfoData, List<Map<String, dynamic>> orderItems) async {
    final tableInfo = _controller._stateManager._parseTableInfo(tableInfoData);
    final state = _controller.getTableState(tableId);

    // Check if there's an existing order and customer info has changed
    if (state.isReorderScenario && state.placedOrderId.value != null) {
      final hasCustomerInfo = state.fullNameController.text.trim().isNotEmpty ||
          state.phoneController.text.trim().isNotEmpty;

      // Update customer info if provided
      if (hasCustomerInfo) {
        await updateCustomerInfo(
          state.placedOrderId.value!,
          state.fullNameController.text.trim(),
          state.phoneController.text.trim(),
        );
      }
    }

    await _processOrder(tableId, context, tableInfo, orderItems, 'KOT sent to manager');
  }



  Future<void> _processOrder(int tableId, BuildContext context, TableInfo? tableInfo, List<Map<String, dynamic>> orderItems, String successMessage) async {
    try {
      _controller.isLoading.value = true;
      final state = _controller.getTableState(tableId);
      final newItems = TableOrderService.getNewItems(state.frozenItems, orderItems);

      if (newItems.isEmpty) {
        SnackBarUtil.showWarning(context, 'No new items to send', title: 'Warning', duration: const Duration(seconds: 2));
        return;
      }

      if (state.isReorderScenario) {
        await _addItemsToExistingOrder(state.placedOrderId.value!, tableId, context, tableInfo, newItems);
      } else {
        await _createNewOrder(tableId, context, tableInfo, state, newItems, successMessage);
      }
    } catch (e) {
      developer.log('Order error: $e', name: 'ORDER_API');
      SnackBarUtil.showError(context, 'Failed to place order', title: 'Error');
    } finally {
      _controller.isLoading.value = false;
    }
  }

  Future<void> _createNewOrder(int tableId, BuildContext context, TableInfo? tableInfo, TableOrderState state, List<Map<String, dynamic>> newItems, String successMessage) async {
    final request = CreateOrderRequest(
      orderData: OrderData(
        hotelTableId: tableInfo?.table.id ?? tableId,
        customerName: state.fullNameController.text.trim(),
        customerPhone: state.phoneController.text.trim(),
        tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
        status: 'pending',
      ),
      items: newItems.map((item) => OrderItemRequest(
        menuItemId: item['id'] as int,
        quantity: item['quantity'] as int,
        specialInstructions: item['special_instructions'] as String?,
      )).toList(),
    );

    final response = await _controller._orderRepository.createOrder(request);
    final orderId = response.data.order.id;
    state.placedOrderId.value = orderId;
    state.addFrozenItems(newItems);

    await showOrderNotification(
      orderId: orderId,
      tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
      itemCount: newItems.length,
      isNewOrder: true,
    );



    _showSuccessAndRefresh(context, tableInfo, tableId, successMessage);
  }

  Future<void> _addItemsToExistingOrder(int orderId, int tableId, BuildContext context, TableInfo? tableInfo, List<Map<String, dynamic>> newItems) async {
    await _controller._orderRepository.addItemsToOrder(orderId, newItems);

    final state = _controller.getTableState(tableId);
    state.addFrozenItems(newItems);

    await showOrderNotification(
      orderId: orderId,
      tableNumber: (tableInfo?.table.tableNumber ?? tableId).toString(),
      itemCount: newItems.length,
      isNewOrder: false,
    );

    _showSuccessAndRefresh(context, tableInfo, tableId, 'Items added to existing order');
  }

  void _showSuccessAndRefresh(BuildContext context, TableInfo? tableInfo, int tableId, String message) {
    final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
    SnackBarUtil.showSuccess(context, '$message for Table $tableNumber', title: 'Success', duration: const Duration(seconds: 2));

    // 🆕 Reset navigation flag after successful order
    _controller.resetNavigationFlag();

    _controller.getTableState(tableId).hasLoadedOrder.value = false;
    Get.find<TakeOrdersController>().refreshTables();
    NavigationService.goBack();
  }

  /// Update customer information for existing order
  Future<void> updateCustomerInfo(int orderId, String customerName, String customerPhone,) async {
    try {
      _controller.isLoading.value = true;

      await _controller._orderRepository.updateCustomerInformation(
        orderId,
        customerName.trim(),
        customerPhone.trim(),
      );

      developer.log('✅ Customer info updated for order: $orderId', name: 'ORDER_API');


      Fluttertoast.showToast(
        msg: 'Customer information updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
      );


    } catch (e) {
      developer.log('❌ Error updating customer info: $e', name: 'ORDER_API');
    } finally {
      _controller.isLoading.value = false;
    }
  }




}

// ==================== UI HELPER ====================
class _UIHelper {
  final OrderManagementController _controller;
  _UIHelper(this._controller);

  void toggleUrgentForTable(int tableId, BuildContext context, dynamic tableInfoData) {
    final tableInfo = _controller._stateManager._parseTableInfo(tableInfoData);
    final state = _controller.getTableState(tableId);
    state.isMarkAsUrgent.value = !state.isMarkAsUrgent.value;

    final tableNumber = tableInfo?.table.tableNumber ?? tableId.toString();
    final message = state.isMarkAsUrgent.value ? 'Table $tableNumber marked as urgent' : 'Table $tableNumber removed from urgent';

    SnackBarUtil.show(context, message,
        title: state.isMarkAsUrgent.value ? 'Marked as urgent' : 'Normal priority',
        type: state.isMarkAsUrgent.value ? SnackBarType.success : SnackBarType.info,
        duration: const Duration(seconds: 1));
  }

  void navigateToAddItems(int tableId, dynamic tableInfoData) {
    try {
      // 🆕 Set flag before navigation
      _controller.setComingFromAddItems(true);

      final tableMap = tableInfoData is TableInfo ? tableInfoToMap(tableInfoData) : (tableInfoData as Map<String, dynamic>?);
      NavigationService.addItems(tableMap);
    } catch (e) {
      developer.log('Navigation error: $e', name: 'UI');
      // 🆕 Reset flag on error
      _controller.resetNavigationFlag();
      SnackBarUtil.showError(Get.context!, 'Unable to proceed', title: 'Error');
    }
  }

  bool canProceedToCheckout(int tableId) {
    return _controller.getTableState(tableId).isAvailableForNewOrder;
  }

  // Public method for external use
  Map<String, dynamic>? tableInfoToMap(TableInfo? tableInfo) {
    if (tableInfo == null) return null;
    return {
      'id': tableInfo.table.id,
      'tableNumber': tableInfo.table.tableNumber,
      'tableType': tableInfo.table.tableType,
      'capacity': tableInfo.table.capacity,
      'status': tableInfo.table.status,
      'description': tableInfo.table.description,
      'location': tableInfo.table.location,
      'areaName': tableInfo.areaName,
      'hotelOwnerId': tableInfo.table.hotelOwnerId,
      'tableAreaId': tableInfo.table.tableAreaId,
      'createdAt': tableInfo.table.createdAt,
      'updatedAt': tableInfo.table.updatedAt,
      'currentOrder': tableInfo.currentOrder?.toJson(),
    };
  }
}

