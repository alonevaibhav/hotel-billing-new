import 'package:flutter/material.dart' hide Table;
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../core/constants/api_constant.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/ResponseModel/table_model.dart';
import '../../../route/app_routes.dart';
import '../../../core/utils/snakbar_utils.dart';
import '../../service/socket_connection_manager.dart';

class TakeOrdersController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final tableResponseModel = Rxn<TableResponseModel>();
  final groupedTables = RxMap<String, List<TableInfo>>();
  final allTables = <TableInfo>[].obs;
  final isSocketConnected = false.obs;

  // Socket & debounce
  final SocketConnectionManager _socketManager = SocketConnectionManager.instance;
  Timer? _refreshDebounceTimer;
  final _refreshDebounceDelay = const Duration(milliseconds: 500);
  bool _isRefreshing = false;
  final Set<String> _processedEvents = {};

  @override
  void onInit() {
    super.onInit();
    developer.log('TakeOrdersController initialized', name: 'TakeOrders');

    // ✅ Setup debug listener first
    _setupDebugListener();

    _setupSocketListeners();
    isSocketConnected.value = _socketManager.connectionStatus;
    fetchTablesData();
  }

  @override
  void onClose() {
    _refreshDebounceTimer?.cancel();
    _removeSocketListeners();
    developer.log('TakeOrdersController disposed', name: 'TakeOrders');
    super.onClose();
  }

  /// ==================== DEBUG LISTENER ====================

  /// ✅ Catch-all listener to intercept ALL socket events
  void _setupDebugListener() {
    developer.log('🔍 Setting up debug listener for ALL events', name: 'TakeOrders.Debug');

    _socketManager.socketService.socket?.onAny((event, data) {
      developer.log(
          '🔔 [DEBUG] Socket event: $event\nData: $data',
          name: 'TakeOrders.Debug'
      );

      // ✅ Manual routing to handlers (bypass broken SocketService.on())
      switch (event) {
        case 'new_order':
          developer.log('🎯 Manually calling handler: new_order', name: 'TakeOrders.Debug');
          _handleNewOrder(data);
          break;
        case 'order_status_update':
          developer.log('🎯 Manually calling handler: order_status_update', name: 'TakeOrders.Debug');
          _handleGenericUpdate(data);
          break;
        case 'payment_update':
          developer.log('🎯 Manually calling handler: payment_update', name: 'TakeOrders.Debug');
          _handlePaymentUpdate(data);
          break;
        case 'table_status_update':
          developer.log('🎯 Manually calling handler: table_status_update', name: 'TakeOrders.Debug');
          _handleGenericUpdate(data);
          break;
        case 'placeOrder_ack':
          developer.log('🎯 Manually calling handler: placeOrder_ack', name: 'TakeOrders.Debug');
          _handleGenericUpdate(data);
          break;
        case 'order_completed':
          developer.log('🎯 Manually calling handler: order_completed', name: 'TakeOrders.Debug');
          _handleGenericUpdate(data);
          break;
        case 'payment_completed':
        case 'table_cleared':
        case 'table_freed':
          developer.log('🎯 Manually calling handler: table_freed', name: 'TakeOrders.Debug');
          _handleTableFreed(data);
          break;
      }
    });
  }

  /// ==================== SOCKET SETUP ====================

  void _setupSocketListeners() {
    developer.log('🔌 Setting up socket listeners', name: 'TakeOrders.Socket');
    _removeSocketListeners();

    // Map event names to handlers
    final eventHandlers = {
      'new_order': _handleNewOrder,
      'order_status_update': _handleGenericUpdate,
      'payment_update': _handlePaymentUpdate,
      'table_status_update': _handleGenericUpdate,
      'placeOrder_ack': _handleGenericUpdate,
      'order_completed': _handleGenericUpdate,
      'payment_completed': _handleTableFreed,
      'table_cleared': _handleTableFreed,
      'table_freed': _handleTableFreed,
    };

    // Register all handlers (still needed for logging purposes)
    eventHandlers.forEach((event, handler) {
      _socketManager.socketService.on(event, handler);
    });

    // Monitor connection status
    ever(_socketManager.isConnected, _onSocketConnectionChanged);

    developer.log('✅ Socket listeners registered', name: 'TakeOrders.Socket');
  }

  void _removeSocketListeners() {
    final events = [
      'new_order', 'order_status_update', 'payment_update',
      'table_status_update', 'placeOrder_ack', 'order_completed',
      'payment_completed', 'table_cleared', 'table_freed'
    ];
    events.forEach(_socketManager.socketService.off);
    developer.log('✅ Socket listeners removed', name: 'TakeOrders.Socket');
  }

  void _onSocketConnectionChanged(bool connected) {
    isSocketConnected.value = connected;
    developer.log('Socket connection: $connected', name: 'TakeOrders.Socket');

    if (Get.context != null) {
      SnackBarUtil.show(
        Get.context!,
        connected ? 'Real-time updates enabled' : 'Real-time updates disconnected',
        title: connected ? '✅ Connected' : '⚠️ Disconnected',
        type: connected ? SnackBarType.success : SnackBarType.warning,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// ==================== SOCKET EVENT HANDLERS ====================

  void _handleNewOrder(dynamic rawData) {
    developer.log('🔔 NEW ORDER HANDLER CALLED', name: 'TakeOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) {
      developer.log('❌ Failed to parse data', name: 'TakeOrders.Socket');
      return;
    }

    developer.log('✅ Data parsed successfully', name: 'TakeOrders.Socket');

    // Check for duplicates
    final orderData = data['data'] ?? data;
    final orderId = _extractOrderId(orderData);
    final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    final eventId = '$orderId-$timestamp';

    if (_isDuplicateEvent(eventId)) {
      developer.log('⏭️ Duplicate event skipped', name: 'TakeOrders.Socket');
      return;
    }

    final tableNumber = _extractTableNumber(orderData);
    final message = data['message'] ?? 'New order received for Table $tableNumber';

    developer.log('📋 Order #$orderId, Table $tableNumber', name: 'TakeOrders.Socket');
    developer.log('🔄 Triggering table refresh...', name: 'TakeOrders.Socket');

    _debouncedRefreshTables();
  }

  void _handlePaymentUpdate(dynamic rawData) {
    developer.log('💰 PAYMENT UPDATE HANDLER CALLED', name: 'TakeOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) return;

    final orderData = data['data'] ?? data;
    final tableId = _extractTableId(orderData);
    final message = data['message'] ?? 'Payment completed';

    developer.log('💰 Payment update for table ID: $tableId', name: 'TakeOrders.Socket');

    _debouncedRefreshTables();

    // Optimistic update
    if (tableId != null) {
      _updateLocalTableStatus(tableId, 'available');
    }
  }

  void _handleTableFreed(dynamic rawData) {
    developer.log('🆓 TABLE FREED HANDLER CALLED', name: 'TakeOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) return;

    final eventType = _getEventType(rawData);
    developer.log('Event type: $eventType', name: 'TakeOrders.Socket');

    final tableData = data['data'] ?? data;
    final tableId = _extractTableId(tableData);
    final tableNumber = _extractTableNumber(tableData);

    developer.log('Table #$tableNumber (ID: $tableId) freed', name: 'TakeOrders.Socket');

    _debouncedRefreshTables();

    // Optimistic update
    if (tableId != null) {
      _updateLocalTableStatus(tableId, 'available');
    }

    if (Get.context != null) {
      final icons = {'payment_completed': '💰', 'table_cleared': '🧹', 'table_freed': '🆓'};
      final icon = icons[eventType] ?? '✅';
    }
  }

  void _handleGenericUpdate(dynamic rawData) {
    developer.log('📊 GENERIC UPDATE HANDLER CALLED', name: 'TakeOrders.Socket');

    final data = _parseSocketData(rawData);
    if (data == null) return;

    developer.log('📊 Triggering refresh...', name: 'TakeOrders.Socket');
    _debouncedRefreshTables();
  }

  /// ==================== HELPER METHODS ====================

  Map<String, dynamic>? _parseSocketData(dynamic rawData) {
    try {
      return rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    } catch (e) {
      developer.log('❌ Parse error: $e', name: 'TakeOrders.Socket.Error');
      return null;
    }
  }

  bool _isDuplicateEvent(String eventId) {
    if (_processedEvents.contains(eventId)) {
      developer.log('⏭️ SKIPPING duplicate: $eventId', name: 'TakeOrders.Socket');
      return true;
    }
    _processedEvents.add(eventId);
    if (_processedEvents.length > 50) _processedEvents.clear();
    return false;
  }

  int _extractOrderId(Map<String, dynamic>? data) {
    return data?['id'] ?? data?['order_id'] ?? data?['orderId'] ?? 0;
  }

  int? _extractTableId(Map<String, dynamic>? data) {
    return data?['tableId'] ?? data?['table_id'] ?? data?['hotel_table_id'];
  }

  String _extractTableNumber(Map<String, dynamic>? data) {
    return data?['table_number']?.toString() ??
        data?['tableNumber']?.toString() ??
        'Unknown';
  }

  String _getEventType(dynamic rawData) {
    if (rawData is Map && rawData.containsKey('event')) {
      return rawData['event'];
    }
    return '📊 UPDATE';
  }

  void _updateLocalTableStatus(int tableId, String newStatus) {
    try {
      final tableIndex = allTables.indexWhere((t) => t.table.id == tableId);
      if (tableIndex == -1) {
        developer.log('⚠️ Table #$tableId not found', name: 'TakeOrders.Socket');
        return;
      }

      final tableInfo = allTables[tableIndex];
      final updatedTable = Table(
        id: tableInfo.table.id,
        hotelOwnerId: tableInfo.table.hotelOwnerId,
        tableAreaId: tableInfo.table.tableAreaId,
        tableNumber: tableInfo.table.tableNumber,
        tableType: tableInfo.table.tableType,
        capacity: tableInfo.table.capacity,
        status: newStatus,
        description: tableInfo.table.description,
        location: tableInfo.table.location,
        createdAt: tableInfo.table.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      allTables[tableIndex] = TableInfo(
        table: updatedTable,
        currentOrder: newStatus == 'available' ? null : tableInfo.currentOrder,
        areaName: tableInfo.areaName,
      );

      _groupTablesByArea(allTables);
      developer.log('✅ Table #$tableId → $newStatus', name: 'TakeOrders.Socket');
    } catch (e, stackTrace) {
      developer.log('❌ Update error: $e\n$stackTrace', name: 'TakeOrders.Socket.Error');
    }
  }

  void _debouncedRefreshTables() {
    developer.log('🔄 Debouncing table refresh...', name: 'TakeOrders.Socket');
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(_refreshDebounceDelay, () {
      if (!_isRefreshing) {
        developer.log('⏰ Executing debounced refresh', name: 'TakeOrders.Socket');
        fetchTablesData();
      } else {
        developer.log('⏭️ Refresh already in progress', name: 'TakeOrders.Socket');
      }
    });
  }

  /// ==================== API METHODS ====================

  Future<void> fetchTablesData() async {
    if (_isRefreshing) {
      developer.log('⏭️ Already refreshing', name: 'TakeOrders');
      return;
    }

    try {
      _isRefreshing = true;
      isLoading.value = true;
      errorMessage.value = '';

      developer.log('📡 Fetching tables...', name: 'TakeOrders');

      final apiResponse = await ApiService.get<TableResponseModel>(
        endpoint: ApiConstants.waiterGetTable,
        fromJson: (json) => TableResponseModel.fromJson(json),
        includeToken: true,
      );

      if (apiResponse?.data != null) {
        final response = apiResponse!.data!;
        if (response.success && response.data != null) {
          tableResponseModel.value = response;
          allTables.value = response.data!.tables;
          _groupTablesByArea(response.data!.tables);

          developer.log('✅ ${allTables.length} tables loaded', name: 'TakeOrders');

          // Force UI update
          allTables.refresh();
          groupedTables.refresh();
        } else {
          errorMessage.value = response.message.isNotEmpty ? response.message : 'Failed to load tables';
          developer.log('❌ API error: ${errorMessage.value}', name: 'TakeOrders');
        }
      } else {
        errorMessage.value = 'Failed to load tables data';
        developer.log('❌ No data received', name: 'TakeOrders');
      }
    } catch (e) {
      errorMessage.value = 'Error loading tables: ${e.toString()}';
      developer.log('❌ Fetch error: $e', name: 'TakeOrders.Error');
    } finally {
      isLoading.value = false;
      _isRefreshing = false;
      developer.log('✅ Fetch completed', name: 'TakeOrders');
    }
  }

  void _groupTablesByArea(List<TableInfo> tables) {
    groupedTables.clear();
    for (var tableInfo in tables) {
      groupedTables.putIfAbsent(tableInfo.areaName, () => []).add(tableInfo);
    }
    developer.log('Tables grouped into ${groupedTables.length} areas', name: 'TakeOrders');
  }

  /// ==================== PUBLIC METHODS ====================

  List<TableInfo> getTablesForArea(String areaName) => groupedTables[areaName] ?? [];

  TableInfo? getTableById(int tableId) {
    try {
      return allTables.firstWhere((table) => table.table.id == tableId);
    } catch (e) {
      return null;
    }
  }

  int calculateElapsedTime(String createdAt) {
    try {
      final orderTime = DateTime.parse(createdAt);
      return DateTime.now().difference(orderTime).inMinutes;
    } catch (e) {
      developer.log('❌ Elapsed time error: $e', name: 'TakeOrders.Error');
      return 0;
    }
  }

  // Handle table selection
  void handleTableTap(TableInfo tableInfo, BuildContext context) {
    try {
      final tableNumber = tableInfo.table.tableNumber;
      final isOccupied = tableInfo.table.status == 'occupied';

      developer.log(
        'Table tapped: Table $tableNumber (ID: ${tableInfo.table.id}), Status: ${tableInfo.table.status}',
        name: 'TakeOrders',
      );

      // Pass the complete table data
      NavigationService.selectItem(tableInfo);

      if (isOccupied && tableInfo.currentOrder != null) {
        final order = tableInfo.currentOrder!;
        SnackBarUtil.showInfo(
          context,
          'Table $tableNumber - Order #${order.orderId} (₹${order.totalAmount})',
          title: 'Occupied Table',
          duration: const Duration(seconds: 2),
        );
      } else if (isOccupied) {
        SnackBarUtil.showInfo(
          context,
          'Table $tableNumber is occupied',
          title: 'Table Info',
          duration: const Duration(seconds: 1),
        );
      } else {
        SnackBarUtil.showSuccess(
          context,
          'Table $tableNumber selected successfully',
          title: 'Available Table',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      developer.log(
        'Error handling table tap: ${e.toString()}',
        name: 'TakeOrders.Error',
      );
      SnackBarUtil.showError(
        context,
        'Failed to select table',
        title: 'Error',
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> refreshTables() async {
    developer.log('♻️ Manual refresh', name: 'TakeOrders');
    await fetchTablesData();
  }

  // Getters
  int get occupiedTablesCount => allTables.where((t) => t.table.status == 'occupied').length;
  int get availableTablesCount => allTables.where((t) => t.table.status == 'available').length;
  int get totalRevenue => allTables
      .where((t) => t.currentOrder != null)
      .fold<int>(0, (sum, t) => sum + (t.currentOrder?.totalAmount?.round() ?? 0));
  bool get socketConnected => isSocketConnected.value;
  Map<String, dynamic> getSocketInfo() => _socketManager.getConnectionInfo();
}