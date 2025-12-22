//
//
// import '../../core/constants/api_constant.dart';
// import '../../core/services/api_service.dart';
// import '../models/ResponseModel/pending_orders_model.dart';
//
// class PendingOrdersRepository {
//   /// Fetch all pending orders and group them by order_id and table_number
//   Future<List<GroupedOrder>> getPendingOrders() async {
//     try {
//       final response = await ApiService.get<PendingOrdersResponse>(
//         endpoint: ApiConstants.chefGetAllOrder,
//         fromJson: (json) => PendingOrdersResponse.fromJson(json),
//         includeToken: true,
//       );
//
//       if (!response.success) {
//         throw Exception('Failed to fetch pending orders: ${response.errorMessage}');
//       }
//
//       final responseData = response.data;
//       if (responseData == null) {
//         return [];
//       }
//
//       // Group items by order_id and table_number
//       return _groupOrderItems(responseData.data.items);
//     } catch (e) {
//       throw Exception('Error fetching pending orders: $e');
//     }
//   }
//
//   /// Update a single order item status (for accept/preparing)
//   Future<void> updateOrderItemStatus({
//     required int orderId,
//     required int itemId,
//     required String status,
//   }) async {
//     try {
//       final body = <String, dynamic>{
//         'item_status': status,
//       };
//
//       final response = await ApiService.patch(
//         endpoint: ApiConstants.chefPatchOrderUpdate(orderId, itemId),
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
//   /// Reject a single order item with reason and category
//   Future<void> rejectOrderItem({
//     required int orderId,
//     required int itemId,
//     required String rejectionReason,
//     String rejectionCategory = 'out_of_stock',
//   }) async {
//     try {
//       final body = <String, dynamic>{
//         'rejection_reason': rejectionReason,
//         'rejection_category': rejectionCategory,
//       };
//
//       final response = await ApiService.post(
//         endpoint: ApiConstants.chefPostOrderReject(orderId, itemId),
//         body: body,
//         fromJson: (json) => json as Map<String, dynamic>,
//         includeToken: true,
//       );
//
//       if (!response.success) {
//         throw Exception('Failed to reject order item: ${response.errorMessage}');
//       }
//     } catch (e) {
//       throw Exception('Error rejecting order item: $e');
//     }
//   }
//
//   /// Update all items in an order to preparing status (for accept)
//   Future<void> updateAllOrderItemsStatus({
//     required int orderId,
//     required List<int> itemIds,
//     required String status,
//   }) async {
//     try {
//       // Update each item sequentially
//       for (final itemId in itemIds) {
//         await updateOrderItemStatus(
//           orderId: orderId,
//           itemId: itemId,
//           status: status,
//         );
//       }
//     } catch (e) {
//       throw Exception('Error updating all order items: $e');
//     }
//   }
//
//   /// Reject all items in an order with the same reason
//   Future<void> rejectAllOrderItems({
//     required int orderId,
//     required List<int> itemIds,
//     required String rejectionReason,
//     String rejectionCategory = 'out_of_stock',
//   }) async {
//     try {
//       // Reject each item sequentially
//       for (final itemId in itemIds) {
//         await rejectOrderItem(
//           orderId: orderId,
//           itemId: itemId,
//           rejectionReason: rejectionReason,
//           rejectionCategory: rejectionCategory,
//         );
//       }
//     } catch (e) {
//       throw Exception('Error rejecting all order items: $e');
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

class PendingOrdersRepository {
  /// Fetch all pending orders and group them by order_id and table_number
  Future<List<GroupedOrder>> getPendingOrders() async {
    try {
      final response = await ApiService.get<PendingOrdersResponse>(
        endpoint: ApiConstants.chefGetAllOrder,
        fromJson: (json) => PendingOrdersResponse.fromJson(json),
        includeToken: true,
      );

      if (!response.success) {
        throw Exception('Failed to fetch pending orders: ${response.errorMessage}');
      }

      final responseData = response.data;
      if (responseData == null) {
        return [];
      }

      return _groupOrderItems(responseData.data.items);
    } catch (e) {
      throw Exception('Error fetching pending orders: $e');
    }
  }

  /// Update a single order item status (for accept/preparing)
  Future<void> updateOrderItemStatus({
    required int orderId,
    required int itemId,
    required String status,
  }) async {
    try {
      final body = <String, dynamic>{
        'item_status': status,
      };

      final response = await ApiService.patch(
        endpoint: ApiConstants.chefPatchOrderUpdate(orderId, itemId),
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

  /// Reject a single order item with reason and category
  Future<void> rejectOrderItem({
    required int orderId,
    required int itemId,
    required String rejectionReason,
    String rejectionCategory = 'out_of_stock',
  }) async {
    try {
      final body = <String, dynamic>{
        'rejection_reason': rejectionReason,
        'rejection_category': rejectionCategory,
      };

      final response = await ApiService.post(
        endpoint: ApiConstants.chefPostOrderReject(orderId, itemId),
        body: body,
        fromJson: (json) => json as Map<String, dynamic>,
        includeToken: true,
      );

      if (!response.success) {
        throw Exception('Failed to reject order item: ${response.errorMessage}');
      }
    } catch (e) {
      throw Exception('Error rejecting order item: $e');
    }
  }

  /// Update all items in an order to preparing status (for accept)
  Future<void> updateAllOrderItemsStatus({
    required int orderId,
    required List<int> itemIds,
    required String status,
  }) async {
    try {
      developer.log(
        '🔄 Updating ${itemIds.length} items to status: $status',
        name: 'PendingOrdersRepo',
      );

      for (final itemId in itemIds) {
        developer.log('📤 PATCH request for item #$itemId', name: 'PendingOrdersRepo');

        await updateOrderItemStatus(
          orderId: orderId,
          itemId: itemId,
          status: status,
        );
      }

      developer.log('✅ All ${itemIds.length} items updated', name: 'PendingOrdersRepo');
    } catch (e) {
      throw Exception('Error updating all order items: $e');
    }
  }

  /// Reject all items in an order with the same reason
  Future<void> rejectAllOrderItems({
    required int orderId,
    required List<int> itemIds,
    required String rejectionReason,
    String rejectionCategory = 'out_of_stock',
  }) async {
    try {
      for (final itemId in itemIds) {
        await rejectOrderItem(
          orderId: orderId,
          itemId: itemId,
          rejectionReason: rejectionReason,
          rejectionCategory: rejectionCategory,
        );
      }
    } catch (e) {
      throw Exception('Error rejecting all order items: $e');
    }
  }

  /// Group items by order_id and table_number, then merge duplicate items
  List<GroupedOrder> _groupOrderItems(List<PendingOrderItem>? items) {
    if (items == null || items.isEmpty) {
      return [];
    }

    developer.log('📦 Processing ${items.length} items', name: 'PendingOrdersRepo');

    final Map<String, List<PendingOrderItem>> groupedMap = {};

    for (var item in items) {
      final key = '${item.orderId}_${item.tableNumber}';
      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(item);
    }

    developer.log('🔢 Grouped into ${groupedMap.length} orders', name: 'PendingOrdersRepo');

    return groupedMap.entries.map((entry) {
      final items = entry.value;
      final firstItem = items.first;

      final mergedItems = _mergeDuplicateItems(items);

      developer.log(
        '📊 Order #${firstItem.orderId}: ${items.length} items → ${mergedItems.length} merged items',
        name: 'PendingOrdersRepo',
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

  /// ✅ Merge duplicate items and track all merged IDs
  List<PendingOrderItem> _mergeDuplicateItems(List<PendingOrderItem> items) {
    final Map<String, _MergedItemData> mergedMap = {};

    for (var item in items) {
      final key = '${item.menuItemId}_${item.itemName}_${item.itemStatus}';

      if (mergedMap.containsKey(key)) {
        final existingData = mergedMap[key]!;
        final newQuantity = existingData.item.quantity + item.quantity;
        final newTotalPrice = (existingData.item.totalPriceDouble + item.totalPriceDouble).toStringAsFixed(2);

        developer.log(
          '🔄 Merging: ${item.itemName} - Qty ${existingData.item.quantity} + ${item.quantity} = $newQuantity',
          name: 'PendingOrdersRepo',
        );

        existingData.mergedItemIds.add(item.id);

        developer.log(
          '📝 Merged IDs: ${existingData.mergedItemIds}',
          name: 'PendingOrdersRepo',
        );

        existingData.item = PendingOrderItem(
          id: existingData.item.id,
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
          updatedAt: item.updatedAt,
          isCustomItem: existingData.item.isCustomItem,
          customerName: existingData.item.customerName,
          customerPhone: existingData.item.customerPhone,
          tableNumber: existingData.item.tableNumber,
          counterBilling: existingData.item.counterBilling,
          orderStatus: existingData.item.orderStatus,
          orderCreatedAt: existingData.item.orderCreatedAt,
          mergedItemIds: existingData.mergedItemIds,
        );
      } else {
        mergedMap[key] = _MergedItemData(
          item: item,
          mergedItemIds: [item.id],
        );
      }
    }

    return mergedMap.values.map((data) => data.item).toList();
  }
}

class _MergedItemData {
  PendingOrderItem item;
  List<int> mergedItemIds;

  _MergedItemData({
    required this.item,
    required this.mergedItemIds,
  });
}