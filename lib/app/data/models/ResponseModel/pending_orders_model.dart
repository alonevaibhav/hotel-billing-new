// // lib/models/pending_orders_model.dart
//
// class PendingOrdersResponse {
//   final String message;
//   final bool success;
//   final PendingOrdersData data; // This should be non-nullable
//   final List<dynamic> errors;
//
//   PendingOrdersResponse({
//     required this.message,
//     required this.success,
//     required this.data,
//     required this.errors,
//   });
//
//   factory PendingOrdersResponse.fromJson(Map<String, dynamic> json) {
//     return PendingOrdersResponse(
//       message: json['message'] ?? '',
//       success: json['success'] ?? false,
//       data: PendingOrdersData.fromJson(json['data'] ?? {}), // Provide empty map as fallback
//       errors: json['errors'] ?? [],
//     );
//   }
// }
//
// class PendingOrdersData {
//   final List<PendingOrderItem> items;
//   final int total;
//   final int pages;
//
//   PendingOrdersData({
//     required this.items,
//     required this.total,
//     required this.pages,
//   });
//
//   factory PendingOrdersData.fromJson(Map<String, dynamic> json) {
//     return PendingOrdersData(
//       items: (json['items'] as List<dynamic>?)
//           ?.map((item) => PendingOrderItem.fromJson(item))
//           .toList() ??
//           [],
//       total: json['total'] ?? 0,
//       pages: json['pages'] ?? 0,
//     );
//   }
// }
//
// class PendingOrderItem {
//   final int id;
//   final int orderId;
//   final int menuItemId;
//   final int hotelOwnerId;
//   final String itemName;
//   final int quantity;
//   final String unitPrice;
//   final String totalPrice;
//   final String? specialInstructions;
//   final String itemStatus;
//   final String? createdBy;
//   final String createdAt;
//   final String updatedAt;
//   final int isCustomItem;
//   final String? customerName;
//   final String? customerPhone;
//   final String tableNumber;
//   final int counterBilling;
//   final String orderStatus;
//   final String orderCreatedAt;
//
//   PendingOrderItem({
//     required this.id,
//     required this.orderId,
//     required this.menuItemId,
//     required this.hotelOwnerId,
//     required this.itemName,
//     required this.quantity,
//     required this.unitPrice,
//     required this.totalPrice,
//     this.specialInstructions,
//     required this.itemStatus,
//     this.createdBy,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isCustomItem,
//     this.customerName,
//     this.customerPhone,
//     required this.tableNumber,
//     required this.counterBilling,
//     required this.orderStatus,
//     required this.orderCreatedAt,
//   });
//
//   factory PendingOrderItem.fromJson(Map<String, dynamic> json) {
//     return PendingOrderItem(
//       id: json['id'] ?? 0,
//       orderId: json['order_id'] ?? 0,
//       menuItemId: json['menu_item_id'] ?? 0,
//       hotelOwnerId: json['hotel_owner_id'] ?? 0,
//       itemName: json['item_name'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       unitPrice: json['unit_price']?.toString() ?? '0.00',
//       totalPrice: json['total_price']?.toString() ?? '0.00',
//       specialInstructions: json['special_instructions'],
//       itemStatus: json['item_status'] ?? '',
//       createdBy: json['created_by'],
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       isCustomItem: json['is_custom_item'] ?? 0,
//       customerName: json['customer_name'],
//       customerPhone: json['customer_phone'],
//       tableNumber: json['table_number']?.toString() ?? '',
//       counterBilling: json['counter_billing'] ?? 0,
//       orderStatus: json['order_status'] ?? '',
//       orderCreatedAt: json['order_created_at'] ?? '',
//     );
//   }
//
//   double get unitPriceDouble => double.tryParse(unitPrice) ?? 0.0;
//   double get totalPriceDouble => double.tryParse(totalPrice) ?? 0.0;
// }
//
// // Grouped Order Model for UI
// class GroupedOrder {
//   final int orderId;
//   final String tableNumber;
//   final String? customerName;
//   final List<PendingOrderItem> items;
//   final String orderCreatedAt;
//
//   GroupedOrder({
//     required this.orderId,
//     required this.tableNumber,
//     this.customerName,
//     required this.items,
//     required this.orderCreatedAt,
//   });
//
//   double get totalAmount {
//     return items.fold(0.0, (sum, item) => sum + item.totalPriceDouble);
//   }
//
//   int get totalItemsCount {
//     return items.fold(0, (sum, item) => sum + item.quantity);
//   }
//
//   // Convert to the format expected by your UI
//   Map<String, dynamic> toOrderMap() {
//     return {
//       "tableId": orderId,
//       "tableNumber": tableNumber,
//       "orderNumber": orderId,
//       "items": items.map((item) => {
//         "id": item.menuItemId,
//         "name": item.itemName,
//         "quantity": item.quantity,
//         "price": item.unitPriceDouble,
//         "total_price": item.totalPriceDouble,
//         "special_instructions": item.specialInstructions,
//       }).toList(),
//       "itemCount": totalItemsCount,
//       "totalAmount": totalAmount,
//     };
//   }
// }


// lib/models/pending_orders_model.dart

class PendingOrdersResponse {
  final String message;
  final bool success;
  final PendingOrdersData data; // This should be non-nullable
  final List<dynamic> errors;

  PendingOrdersResponse({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory PendingOrdersResponse.fromJson(Map<String, dynamic> json) {
    return PendingOrdersResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: PendingOrdersData.fromJson(json['data'] ?? {}), // Provide empty map as fallback
      errors: json['errors'] ?? [],
    );
  }
}

class PendingOrdersData {
  final List<PendingOrderItem> items;
  final int total;
  final int pages;

  PendingOrdersData({
    required this.items,
    required this.total,
    required this.pages,
  });

  factory PendingOrdersData.fromJson(Map<String, dynamic> json) {
    return PendingOrdersData(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => PendingOrderItem.fromJson(item))
          .toList() ??
          [],
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }
}

class PendingOrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final int hotelOwnerId;
  final String itemName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final String? specialInstructions;
  final String itemStatus;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final int isCustomItem;
  final String? customerName;
  final String? customerPhone;
  final String tableNumber;
  final int counterBilling;
  final String orderStatus;
  final String orderCreatedAt;

  // ✅ NEW: List of all item IDs that were merged into this item
  final List<int> mergedItemIds;

  PendingOrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.hotelOwnerId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    required this.itemStatus,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isCustomItem,
    this.customerName,
    this.customerPhone,
    required this.tableNumber,
    required this.counterBilling,
    required this.orderStatus,
    required this.orderCreatedAt,
    List<int>? mergedItemIds, // ✅ Optional parameter
  }) : mergedItemIds = mergedItemIds ?? [id]; // ✅ Default to single ID if not provided

  factory PendingOrderItem.fromJson(Map<String, dynamic> json) {
    final itemId = json['id'] ?? 0;
    return PendingOrderItem(
      id: itemId,
      orderId: json['order_id'] ?? 0,
      menuItemId: json['menu_item_id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalPrice: json['total_price']?.toString() ?? '0.00',
      specialInstructions: json['special_instructions'],
      itemStatus: json['item_status'] ?? '',
      createdBy: json['created_by'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isCustomItem: json['is_custom_item'] ?? 0,
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      tableNumber: json['table_number']?.toString() ?? '',
      counterBilling: json['counter_billing'] ?? 0,
      orderStatus: json['order_status'] ?? '',
      orderCreatedAt: json['order_created_at'] ?? '',
      mergedItemIds: [itemId], // ✅ Initialize with single ID from JSON
    );
  }

  double get unitPriceDouble => double.tryParse(unitPrice) ?? 0.0;
  double get totalPriceDouble => double.tryParse(totalPrice) ?? 0.0;
}
// Grouped Order Model for UI
class GroupedOrder {
  final int orderId;
  final String tableNumber;
  final String? customerName;
  final List<PendingOrderItem> items;
  final String orderCreatedAt;

  GroupedOrder({
    required this.orderId,
    required this.tableNumber,
    this.customerName,
    required this.items,
    required this.orderCreatedAt,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPriceDouble);
  }

  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Convert to the format expected by your UI
  Map<String, dynamic> toOrderMap() {
    return {
      "tableId": orderId,
      "tableNumber": tableNumber,
      "orderNumber": orderId,
      "items": items.map((item) => {
        "id": item.menuItemId,
        "name": item.itemName,
        "quantity": item.quantity,
        "price": item.unitPriceDouble,
        "total_price": item.totalPriceDouble,
        "special_instructions": item.specialInstructions,
      }).toList(),
      "itemCount": totalItemsCount,
      "totalAmount": totalAmount,
    };
  }
}