// lib/repositories/pending_orders_repository.dart

import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../models/ResponseModel/pending_orders_model.dart';

class PreparingOrdersRepository {

  /// Fetch all pending orders and group them by order_id and table_number
  Future<List<GroupedOrder>> getPendingOrders() async {
    try {
      final response = await ApiService.get<PendingOrdersResponse>(
        endpoint: ApiConstants.chefGetPreparingOrder,
        fromJson: (json) => PendingOrdersResponse.fromJson(json),
        includeToken: true,
      );

      if (!response.success) {
        throw Exception('Failed to fetch pending orders: ${response.errorMessage}');
      }

      // ✅ FIX: Access data.data.items (PendingOrdersResponse -> PendingOrdersData -> items)
      final responseData = response.data;
      if (responseData == null) {
        return []; // Return empty list if no data
      }

      // Group items by order_id and table_number
      return _groupOrderItems(responseData.data.items);
    } catch (e) {
      throw Exception('Error fetching pending orders: $e');
    }
  }

  /// Update a single order item status
  Future<void> updateOrderItemStatus({
    required int orderId,
    required int itemId,
    required String status,
    String? reason,
  }) async {
    try {
      final endpoint = ApiConstants.chefPatchOrderUpdate(orderId, itemId);

      final body = <String, dynamic>{
        'item_status': status,
      };

      // Add reason if provided (optional)
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await ApiService.patch(
        endpoint: endpoint,
        body: body,
        fromJson: (json) => json as Map<String, dynamic>,
        includeToken: true,
      );

      if (!response.success) {
        throw Exception('Failed to update order item status: ${response.errorMessage}');
      }
    } catch (e) {
      throw Exception('Error updating order item status: $e');
    }
  }

  /// Update all items in an order to the same status
  Future<void> updateAllOrderItemsStatus({
    required int orderId,
    required List<int> itemIds,
    required String status,
    String? reason,
  }) async {
    try {
      // Update each item sequentially
      for (final itemId in itemIds) {
        await updateOrderItemStatus(
          orderId: orderId,
          itemId: itemId,
          status: status,
          reason: reason,
        );
      }
    } catch (e) {
      throw Exception('Error updating all order items: $e');
    }
  }

  /// Group items by order_id and table_number
  List<GroupedOrder> _groupOrderItems(List<PendingOrderItem>? items) {
    if (items == null || items.isEmpty) {
      return [];
    }

    // Create a map with composite key: "orderId_tableNumber"
    final Map<String, List<PendingOrderItem>> groupedMap = {};

    for (var item in items) {
      final key = '${item.orderId}_${item.tableNumber}';

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(item);
    }

    // Convert map to list of GroupedOrder
    return groupedMap.entries.map((entry) {
      final items = entry.value;
      final firstItem = items.first;

      return GroupedOrder(
        orderId: firstItem.orderId,
        tableNumber: firstItem.tableNumber,
        customerName: firstItem.customerName,
        items: items,
        orderCreatedAt: firstItem.orderCreatedAt,
      );
    }).toList()
      ..sort((a, b) => b.orderCreatedAt.compareTo(a.orderCreatedAt));
  }
}