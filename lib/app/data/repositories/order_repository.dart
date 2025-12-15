import 'dart:developer' as developer;
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../../core/services/socket_service.dart';
import '../models/RequestModel/create_order_request.dart';
import '../models/ResponseModel/order_model.dart';

class OrderRepository {
  final SocketService _socketService = SocketService.instance;

  /// Initialize socket listeners for order updates
  void initializeSocketListeners({
    required Function(Map<String, dynamic>) onNewOrder,
    required Function(Map<String, dynamic>) onOrderStatusUpdate,
    required Function(Map<String, dynamic>) onPaymentUpdate,
  }) {
    developer.log(
      '🔌 Initializing socket listeners for orders',
      name: 'ORDER_REPOSITORY',
    );

    _socketService.on('new_order', (data) {
      try {
        developer.log('📦 New order event received: $data', name: 'ORDER_REPOSITORY');

        // ✅ Convert dynamic Map to String-keyed Map
        final orderData = _convertToStringKeyedMap(data);
        onNewOrder(orderData);
      } catch (e) {
        developer.log('❌ Error handling new_order event: $e', name: 'ORDER_REPOSITORY');
      }
    });

    _socketService.on('order_status_update', (data) {
      try {
        developer.log('📊 Status update event received: $data', name: 'ORDER_REPOSITORY');

        // ✅ Convert dynamic Map to String-keyed Map
        final statusData = _convertToStringKeyedMap(data);
        onOrderStatusUpdate(statusData);
      } catch (e) {
        developer.log('❌ Error handling order_status_update event: $e', name: 'ORDER_REPOSITORY');
      }
    });

    _socketService.on('payment_update', (data) {
      try {
        developer.log('💰 Payment update event received: $data', name: 'ORDER_REPOSITORY');

        // ✅ Convert dynamic Map to String-keyed Map
        final paymentData = _convertToStringKeyedMap(data);
        onPaymentUpdate(paymentData);
      } catch (e) {
        developer.log('❌ Error handling payment_update event: $e', name: 'ORDER_REPOSITORY');
      }
    });

    developer.log(
      '✅ Socket listeners initialized successfully',
      name: 'ORDER_REPOSITORY',
    );
  }

  /// Remove socket listeners
  void removeSocketListeners() {
    developer.log(
      '🔌 Removing socket listeners',
      name: 'ORDER_REPOSITORY',
    );

    _socketService.off('new_order');
    _socketService.off('order_status_update');
    _socketService.off('payment_update');
  }

  /// Convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _convertToStringKeyedMap(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    developer.log(
      '⚠️ Unexpected data type: ${data.runtimeType}',
      name: 'ORDER_REPOSITORY',
    );
    return {};
  }

  /// Fetch order details by order ID
  Future<OrderResponseModel> getOrderById(int orderId) async {
    try {
      developer.log(
        'Fetching order with ID: $orderId',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.get<OrderResponseModel>(
        endpoint: ApiConstants.waiterGetTableOrder(orderId),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.errorMessage ?? 'Failed to fetch order');
      }

      developer.log(
        '✅ Order fetched successfully: $orderId',
        name: 'ORDER_REPOSITORY',
      );

      return response.data!;
    } catch (e) {
      developer.log('❌ Error fetching order: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }

  /// Create a new order (REST API only - socket notifications handled by backend)
  Future<OrderResponseModel> createOrder(CreateOrderRequest request) async {
    try {
      developer.log(
        'Creating new order: ${request.toJson()}',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.post<OrderResponseModel>(
        endpoint: ApiConstants.waiterPostCreateOrder,
        body: request.toJson(),
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.errorMessage ?? 'Failed to create order');
      }

      developer.log(
        '✅ Order created: ${response.data!.data.order.id} (Backend will notify other users via socket)',
        name: 'ORDER_REPOSITORY',
      );

      return response.data!;
    } catch (e) {
      developer.log('❌ Error creating order: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }

  /// Add items to existing order (Reorder)
  Future<OrderResponseModel> addItemsToOrder(
      int orderId,
      List<Map<String, dynamic>> items,
      ) async {
    try {
      final requestBody = {
        "items": items.map((item) {
          final reorderItem = <String, dynamic>{
            "menu_item_id": item['id'] as int,
            "quantity": item['quantity'] as int,
          };

          // Fixed: special_instructions is String, not int
          if (item['special_instructions'] != null &&
              item['special_instructions'].toString().trim().isNotEmpty) {
            reorderItem['special_instructions'] =
            item['special_instructions'] as String;
          }

          return reorderItem;
        }).toList(),
      };

      developer.log(
        'Adding items to order $orderId: $requestBody',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.post<OrderResponseModel>(
        endpoint: ApiConstants.waiterPostReorder(orderId),
        body: requestBody,
        fromJson: (json) => OrderResponseModel.fromJson(json),
        includeToken: true,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.errorMessage ?? 'Failed to add items to order');
      }

      developer.log(
        '✅ Items added to order: $orderId (Backend will notify other users via socket)',
        name: 'ORDER_REPOSITORY',
      );

      return response.data!;
    } catch (e) {
      developer.log('❌ Error adding items to order: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }

  /// Update customer information for an existing order
  Future<void> updateCustomerInformation(
      int orderId,
      String customerName,
      String customerPhone,
      ) async {
    try {
      developer.log(
        'Updating customer info for order $orderId',
        name: 'ORDER_REPOSITORY',
      );

      final response = await ApiService.patch(
        endpoint: ApiConstants.waiterPatchInformation(orderId),
        body: {
          'customer_name': customerName,
          'customer_phone': customerPhone,
        },
        includeToken: true,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success) {
        throw Exception(response.errorMessage ?? 'Failed to update customer info');
      }

      developer.log(
        '✅ Customer info updated for order: $orderId',
        name: 'ORDER_REPOSITORY',
      );
    } catch (e) {
      developer.log('❌ Error updating customer info: $e', name: 'ORDER_REPOSITORY');
      rethrow;
    }
  }
}
