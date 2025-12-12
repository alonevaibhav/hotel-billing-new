
class ReadyOrderResponse {
  final String message;
  final bool success;
  final ReadyOrderData data;
  final List<dynamic> errors;

  ReadyOrderResponse({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory ReadyOrderResponse.fromJson(Map<String, dynamic> json) {
    return ReadyOrderResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: ReadyOrderData.fromJson(json['data'] ?? {}),
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data.toJson(),
      'errors': errors,
    };
  }
}

class ReadyOrderData {
  final List<ReadyOrderItem> items;
  final int total;
  final int pages;

  ReadyOrderData({
    required this.items,
    required this.total,
    required this.pages,
  });

  factory ReadyOrderData.fromJson(Map<String, dynamic> json) {
    return ReadyOrderData(
      items: (json['items'] as List?)
          ?.map((item) => ReadyOrderItem.fromJson(item))
          .toList() ??
          [],
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'pages': pages,
    };
  }
}

class ReadyOrderItem {
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
  final String customerName;
  final String customerPhone;
  final String tableNumber;
  final int counterBilling;
  final String orderStatus;
  final String orderCreatedAt;

  ReadyOrderItem({
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
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    required this.counterBilling,
    required this.orderStatus,
    required this.orderCreatedAt,
  });

  factory ReadyOrderItem.fromJson(Map<String, dynamic> json) {
    return ReadyOrderItem(
      id: json['id'] ?? 0,
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
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      counterBilling: json['counter_billing'] ?? 0,
      orderStatus: json['order_status'] ?? '',
      orderCreatedAt: json['order_created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'hotel_owner_id': hotelOwnerId,
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'special_instructions': specialInstructions,
      'item_status': itemStatus,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_custom_item': isCustomItem,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      'counter_billing': counterBilling,
      'order_status': orderStatus,
      'order_created_at': orderCreatedAt,
    };
  }
}

// Helper class to group items by order for display purposes
class GroupedOrder {
  final int orderId;
  final String tableNumber;
  final String customerName;
  final String customerPhone;
  final String orderStatus;
  final String orderCreatedAt;
  final int counterBilling;
  final List<ReadyOrderItem> items;

  GroupedOrder({
    required this.orderId,
    required this.tableNumber,
    required this.customerName,
    required this.customerPhone,
    required this.orderStatus,
    required this.orderCreatedAt,
    required this.counterBilling,
    required this.items,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (double.tryParse(item.totalPrice) ?? 0.0));
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  String get billNumber {
    // Generate bill number from order ID or use a placeholder
    return 'ORD-$orderId';
  }
}