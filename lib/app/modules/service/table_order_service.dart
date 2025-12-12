// lib/app/services/table_order_service.dart

import 'dart:developer' as developer;
import '../../data/models/ResponseModel/order_model.dart' ;
import '../model/froze_model.dart';


/// Service class to handle table order business logic
class TableOrderService {
  /// Calculate items that are new (not frozen)
  static List<Map<String, dynamic>> getNewItems(
      List<FrozenItem> frozenItems,
      List<Map<String, dynamic>> orderItems,
      ) {
    return orderItems.where((item) {
      final frozenQty = _getFrozenQuantity(frozenItems, item['id'].toString());
      final currentQty = item['quantity'] as int;
      return currentQty > frozenQty;
    }).map((item) {
      final frozenQty = _getFrozenQuantity(frozenItems, item['id'].toString());
      final newQty = (item['quantity'] as int) - frozenQty;
      return {
        ...item,
        'quantity': newQty,
        'total_price': (item['price'] as double) * newQty,
      };
    }).toList();
  }

  /// Get frozen quantity for an item
  static int _getFrozenQuantity(List<FrozenItem> frozenItems, String itemId) {
    return frozenItems
        .cast<FrozenItem?>()
        .firstWhere(
          (item) => item?.id == itemId,
      orElse: () => null,
    )
        ?.quantity ??
        0;
  }

  /// Process and group order items from API response
  static List<Map<String, dynamic>> processOrderItems(
      List<OrderItem> apiItems,
      List<FrozenItem> outFrozenItems,
      ) {
    final List<Map<String, dynamic>> localItems = [];

    // Group by menuItemId
    final Map<int, int> groupedQty = {};
    for (final apiItem in apiItems) {
      final id = apiItem.menuItemId;
      groupedQty[id] = (groupedQty[id] ?? 0) + apiItem.quantity;
    }

    // Build single local item per menuItemId
    groupedQty.forEach((id, totalQty) {
      final apiSample = apiItems.firstWhere((e) => e.menuItemId == id);
      final localItem = apiSample.toLocalOrderItem();

      localItem['id'] = id;
      localItem['quantity'] = totalQty;
      localItem['total_price'] =
          (localItem['price'] as double) * totalQty.toDouble();

      localItems.add(localItem);

      // Add to frozen items
      outFrozenItems.add(FrozenItem(
        id: id.toString(),
        name: apiSample.itemName,
        quantity: totalQty,
      ));
    });

    developer.log(
      'Processed ${localItems.length} items from API',
      name: 'TABLE_ORDER_SERVICE',
    );

    return localItems;
  }

  /// Calculate total price from order items
  static double calculateTotal(List<Map<String, dynamic>> orderItems) {
    return orderItems.fold<double>(
      0.0,
          (sum, item) => sum + (item['total_price'] as double),
    );
  }

  /// Update item quantity and total price
  static Map<String, dynamic> updateItemQuantity(
      Map<String, dynamic> item,
      int newQuantity,
      ) {
    final price = item['price'] as double;
    item['quantity'] = newQuantity;
    item['total_price'] = price * newQuantity;

    developer.log(
      'Updated item ${item['item_name']}: qty=$newQuantity, total=${item['total_price']}',
      name: 'TABLE_ORDER_SERVICE',
    );

    return item;
  }

  /// Check if item can be decremented
  static bool canDecrementItem(int currentQty, int frozenQty) {
    return currentQty > frozenQty;
  }

  /// Check if item can be removed
  static bool canRemoveItem(int frozenQty) {
    return frozenQty == 0;
  }

  /// Merge item into existing list or add new
  static void mergeOrAddItem(
      List<Map<String, dynamic>> orderItems,
      Map<String, dynamic> newItem,
      ) {
    final int id = newItem['id'] as int;
    final int qty = newItem['quantity'] as int;
    final double price = newItem['price'] as double;

    final index = orderItems.indexWhere((e) => e['id'] == id);

    if (index >= 0) {
      // Merge: Item already exists
      final existing = orderItems[index];
      final int oldQty = existing['quantity'] as int;
      final int newQty = oldQty + qty;

      existing['quantity'] = newQty;
      existing['total_price'] = price * newQty;
      orderItems[index] = existing;

      developer.log(
        '✅ MERGED: ${newItem['item_name']} - Old: $oldQty, Added: $qty, New Total: $newQty',
        name: 'TABLE_ORDER_SERVICE',
      );
    } else {
      // Add new item
      orderItems.add(newItem);

      developer.log(
        '✅ NEW ITEM: ${newItem['item_name']} - Qty: $qty',
        name: 'TABLE_ORDER_SERVICE',
      );
    }
  }
}