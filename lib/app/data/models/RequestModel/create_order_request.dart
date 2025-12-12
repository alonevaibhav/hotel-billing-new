class CreateOrderRequest {
  final OrderData orderData;
  final List<OrderItemRequest> items;

  CreateOrderRequest({
    required this.orderData,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderData': orderData.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderData {
  final int hotelTableId;
  final String customerName;
  final String customerPhone;
  final String tableNumber;
  final String status;

  OrderData({
    required this.hotelTableId,
    required this.customerName,
    required this.customerPhone,
    required this.tableNumber,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'hotel_table_id': hotelTableId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      'status': status,
    };
  }
}

class OrderItemRequest {
  final int menuItemId;
  final int quantity;
  final String? specialInstructions;

  OrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'menu_item_id': menuItemId,
      'quantity': quantity,
    };


    return map;
  }
}