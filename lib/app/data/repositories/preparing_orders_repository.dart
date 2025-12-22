// // lib/repositories/pending_orders_repository.dart
//
// import '../../core/constants/api_constant.dart';
// import '../../core/services/api_service.dart';
// import '../models/ResponseModel/pending_orders_model.dart';
//
// class PreparingOrdersRepository {
//
//   /// Fetch all pending orders and group them by order_id and table_number
//   Future<List<GroupedOrder>> getPendingOrders() async {
//     try {
//       final response = await ApiService.get<PendingOrdersResponse>(
//         endpoint: ApiConstants.chefGetPreparingOrder,
//         fromJson: (json) => PendingOrdersResponse.fromJson(json),
//         includeToken: true,
//       );
//
//       if (!response.success) {
//         throw Exception('Failed to fetch pending orders: ${response.errorMessage}');
//       }
//
//       // ✅ FIX: Access data.data.items (PendingOrdersResponse -> PendingOrdersData -> items)
//       final responseData = response.data;
//       if (responseData == null) {
//         return []; // Return empty list if no data
//       }
//
//       // Group items by order_id and table_number
//       return _groupOrderItems(responseData.data.items);
//     } catch (e) {
//       throw Exception('Error fetching pending orders: $e');
//     }
//   }
//
//   /// Update a single order item status
//   Future<void> updateOrderItemStatus({
//     required int orderId,
//     required int itemId,
//     required String status,
//     String? reason,
//   }) async {
//     try {
//       final endpoint = ApiConstants.chefPatchOrderUpdate(orderId, itemId);
//
//       final body = <String, dynamic>{
//         'item_status': status,
//       };
//
//       // Add reason if provided (optional)
//       if (reason != null && reason.isNotEmpty) {
//         body['reason'] = reason;
//       }
//
//       final response = await ApiService.patch(
//         endpoint: endpoint,
//         body: body,
//         fromJson: (json) => json as Map<String, dynamic>,
//         includeToken: true,
//       );
//
//       if (!response.success) {
//         throw Exception('Failed to update order item status: ${response.errorMessage}');
//       }
//     } catch (e) {
//       throw Exception('Error updating order item status: $e');
//     }
//   }
//
//   /// Update all items in an order to the same status
//   Future<void> updateAllOrderItemsStatus({
//     required int orderId,
//     required List<int> itemIds,
//     required String status,
//     String? reason,
//   }) async {
//     try {
//       // Update each item sequentially
//       for (final itemId in itemIds) {
//         await updateOrderItemStatus(
//           orderId: orderId,
//           itemId: itemId,
//           status: status,
//           reason: reason,
//         );
//       }
//     } catch (e) {
//       throw Exception('Error updating all order items: $e');
//     }
//   }
//
//   /// Group items by order_id and table_number
//   List<GroupedOrder> _groupOrderItems(List<PendingOrderItem>? items) {
//     if (items == null || items.isEmpty) {
//       return [];
//     }
//
//     // Create a map with composite key: "orderId_tableNumber"
//     final Map<String, List<PendingOrderItem>> groupedMap = {};
//
//     for (var item in items) {
//       final key = '${item.orderId}_${item.tableNumber}';
//
//       if (!groupedMap.containsKey(key)) {
//         groupedMap[key] = [];
//       }
//       groupedMap[key]!.add(item);
//     }
//
//     // Convert map to list of GroupedOrder
//     return groupedMap.entries.map((entry) {
//       final items = entry.value;
//       final firstItem = items.first;
//
//       return GroupedOrder(
//         orderId: firstItem.orderId,
//         tableNumber: firstItem.tableNumber,
//         customerName: firstItem.customerName,
//         items: items,
//         orderCreatedAt: firstItem.orderCreatedAt,
//       );
//     }).toList()
//       ..sort((a, b) => b.orderCreatedAt.compareTo(a.orderCreatedAt));
//   }
// }

import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../models/ResponseModel/pending_orders_model.dart';
import 'dart:developer' as developer;

class PreparingOrdersRepository {
  /// Fetch all preparing orders and group them by order_id and table_number
  Future<List<GroupedOrder>> getPendingOrders() async {
    try {
      final response = await ApiService.get<PendingOrdersResponse>(
        endpoint: ApiConstants.chefGetPreparingOrder,
        fromJson: (json) => PendingOrdersResponse.fromJson(json),
        includeToken: true,
      );

      if (!response.success) {
        throw Exception('Failed to fetch preparing orders: ${response.errorMessage}');
      }

      final responseData = response.data;
      if (responseData == null) {
        return [];
      }

      // Group items by order_id and table_number
      return _groupOrderItems(responseData.data.items);
    } catch (e) {
      throw Exception('Error fetching preparing orders: $e');
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
      developer.log(
        '🔄 Updating ${itemIds.length} items to status: $status',
        name: 'PreparingOrdersRepo',
      );

      // Update each item sequentially
      for (final itemId in itemIds) {
        developer.log(
          '📤 PATCH request for item #$itemId',
          name: 'PreparingOrdersRepo',
        );

        await updateOrderItemStatus(
          orderId: orderId,
          itemId: itemId,
          status: status,
          reason: reason,
        );
      }

      developer.log(
        '✅ All ${itemIds.length} items updated successfully',
        name: 'PreparingOrdersRepo',
      );
    } catch (e) {
      throw Exception('Error updating all order items: $e');
    }
  }

  /// Group items by order_id and table_number, then merge duplicate items
  List<GroupedOrder> _groupOrderItems(List<PendingOrderItem>? items) {
    if (items == null || items.isEmpty) {
      return [];
    }

    developer.log('📦 Processing ${items.length} preparing items', name: 'PreparingOrdersRepo');

    // Create a map with composite key: "orderId_tableNumber"
    final Map<String, List<PendingOrderItem>> groupedMap = {};

    for (var item in items) {
      final key = '${item.orderId}_${item.tableNumber}';

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(item);
    }

    developer.log('🔢 Grouped into ${groupedMap.length} orders', name: 'PreparingOrdersRepo');

    // Convert map to list of GroupedOrder and merge duplicate items
    return groupedMap.entries.map((entry) {
      final items = entry.value;
      final firstItem = items.first;

      // ✅ Merge duplicate items before creating GroupedOrder
      final mergedItems = _mergeDuplicateItems(items);

      developer.log(
        '📊 Order #${firstItem.orderId}: ${items.length} items → ${mergedItems.length} merged items',
        name: 'PreparingOrdersRepo',
      );

      return GroupedOrder(
        orderId: firstItem.orderId,
        tableNumber: firstItem.tableNumber,
        customerName: firstItem.customerName,
        items: mergedItems,
        orderCreatedAt: firstItem.orderCreatedAt,
      );
    }).toList()
      ..sort((a, b) => b.orderCreatedAt.compareTo(a.orderCreatedAt));
  }

  /// ✅ Merge duplicate items based on menu_item_id, item_name, and item_status
  /// IMPORTANT: Stores ALL original item IDs in mergedItemIds for batch updates
  List<PendingOrderItem> _mergeDuplicateItems(List<PendingOrderItem> items) {
    final Map<String, _MergedItemData> mergedMap = {};

    for (var item in items) {
      // Create unique key: "menuItemId_itemName_itemStatus"
      final key = '${item.menuItemId}_${item.itemName}_${item.itemStatus}';

      if (mergedMap.containsKey(key)) {
        // Item already exists, merge quantities and prices
        final existingData = mergedMap[key]!;

        final newQuantity = existingData.item.quantity + item.quantity;
        final newTotalPrice = (existingData.item.totalPriceDouble + item.totalPriceDouble).toStringAsFixed(2);

        developer.log(
          '🔄 Merging: ${item.itemName} - Qty ${existingData.item.quantity} + ${item.quantity} = $newQuantity',
          name: 'PreparingOrdersRepo',
        );

        // ✅ Add this item's ID to the list of merged IDs
        existingData.mergedItemIds.add(item.id);

        developer.log(
          '📝 Merged IDs for ${item.itemName}: ${existingData.mergedItemIds}',
          name: 'PreparingOrdersRepo',
        );

        // Create merged item with combined quantities
        existingData.item = PendingOrderItem(
          id: existingData.item.id, // Keep first item's ID as primary
          orderId: existingData.item.orderId,
          menuItemId: existingData.item.menuItemId,
          hotelOwnerId: existingData.item.hotelOwnerId,
          itemName: existingData.item.itemName,
          quantity: newQuantity,
          unitPrice: existingData.item.unitPrice,
          totalPrice: newTotalPrice,
          specialInstructions: existingData.item.specialInstructions,
          itemStatus: existingData.item.itemStatus,
          createdBy: existingData.item.createdBy,
          createdAt: existingData.item.createdAt,
          updatedAt: item.updatedAt, // Use latest update time
          isCustomItem: existingData.item.isCustomItem,
          customerName: existingData.item.customerName,
          customerPhone: existingData.item.customerPhone,
          tableNumber: existingData.item.tableNumber,
          counterBilling: existingData.item.counterBilling,
          orderStatus: existingData.item.orderStatus,
          orderCreatedAt: existingData.item.orderCreatedAt,
          mergedItemIds: existingData.mergedItemIds, // ✅ Store all merged IDs
        );
      } else {
        // First occurrence of this item - initialize with its own ID
        mergedMap[key] = _MergedItemData(
          item: item,
          mergedItemIds: [item.id], // ✅ Start with this item's ID
        );
      }
    }

    return mergedMap.values.map((data) => data.item).toList();
  }
}

/// Helper class to track merged item IDs during the merge process
class _MergedItemData {
  PendingOrderItem item;
  List<int> mergedItemIds;

  _MergedItemData({
    required this.item,
    required this.mergedItemIds,
  });
}