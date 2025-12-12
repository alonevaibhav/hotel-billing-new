// order_response_model.dart

class OrderResponseModel {
  final String message;
  final bool success;
  final OrderData data;
  final List<dynamic> errors;

  OrderResponseModel({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: OrderData.fromJson(json['data'] ?? {}),
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

class OrderData {
  final Order order;
  final List<OrderItem> items;
  final String subtotal;
  final String taxAmount;
  final String finalAmount;

  OrderData({
    required this.order,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.finalAmount,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      order: Order.fromJson(json['order'] ?? {}),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ??
          [],
      subtotal: json['subtotal']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      finalAmount: json['final_amount']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'final_amount': finalAmount,
    };
  }
}

class Order {
  final int id;
  final int hotelOwnerId;
  final int hotelTableId;
  final int counterBilling;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final String? upiId;
  final String? displayName;
  final String status;
  final String? specialInstructions;
  final String totalAmount;
  final String taxAmount;
  final String discount;
  final String finalAmount;
  final String createdAt;
  final String updatedAt;
  final String billNumber;
  final int includeGst;
  final String gstPercentage;
  final String cgstPercentage;
  final String sgstPercentage;
  final String cgstAmount;
  final String sgstAmount;
  final dynamic gstBreakdown;
  final String tableNumber;
  final String tableType;
  final int capacity;
  final String? tableLocation;
  final String cgst;
  final String sgst;

  Order({
    required this.id,
    required this.hotelOwnerId,
    required this.hotelTableId,
    required this.counterBilling,
    this.customerName,
    this.customerPhone,
    required this.paymentMethod,
    this.upiId,
    this.displayName,
    required this.status,
    this.specialInstructions,
    required this.totalAmount,
    required this.taxAmount,
    required this.discount,
    required this.finalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.billNumber,
    required this.includeGst,
    required this.gstPercentage,
    required this.cgstPercentage,
    required this.sgstPercentage,
    required this.cgstAmount,
    required this.sgstAmount,
    this.gstBreakdown,
    required this.tableNumber,
    required this.tableType,
    required this.capacity,
    this.tableLocation,
    required this.cgst,
    required this.sgst,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      hotelTableId: json['hotel_table_id'] ?? 0,
      counterBilling: json['counter_billing'] ?? 0,
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      paymentMethod: json['payment_method'] ?? 'cash',
      upiId: json['upi_id'],
      displayName: json['display_name'],
      status: json['status'] ?? 'pending',
      specialInstructions: json['special_instructions'],
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      finalAmount: json['final_amount']?.toString() ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      billNumber: json['bill_number'] ?? '',
      includeGst: json['include_gst'] ?? 0,
      gstPercentage: json['gst_percentage']?.toString() ?? '0.00',
      cgstPercentage: json['cgst_percentage']?.toString() ?? '0.00',
      sgstPercentage: json['sgst_percentage']?.toString() ?? '0.00',
      cgstAmount: json['cgst_amount']?.toString() ?? '0.00',
      sgstAmount: json['sgst_amount']?.toString() ?? '0.00',
      gstBreakdown: json['gst_breakdown'],
      tableNumber: json['table_number']?.toString() ?? '',
      tableType: json['table_type'] ?? 'standard',
      capacity: json['capacity'] ?? 0,
      tableLocation: json['table_location'],
      cgst: json['cgst']?.toString() ?? '0.00',
      sgst: json['sgst']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_owner_id': hotelOwnerId,
      'hotel_table_id': hotelTableId,
      'counter_billing': counterBilling,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'payment_method': paymentMethod,
      'upi_id': upiId,
      'display_name': displayName,
      'status': status,
      'special_instructions': specialInstructions,
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'discount': discount,
      'final_amount': finalAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'bill_number': billNumber,
      'include_gst': includeGst,
      'gst_percentage': gstPercentage,
      'cgst_percentage': cgstPercentage,
      'sgst_percentage': sgstPercentage,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'gst_breakdown': gstBreakdown,
      'table_number': tableNumber,
      'table_type': tableType,
      'capacity': capacity,
      'table_location': tableLocation,
      'cgst': cgst,
      'sgst': sgst,
    };
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final int hotelOwnerId;
  final String itemName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final String? specialInstructions;
  final String createdAt;
  final int isCustomItem;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.hotelOwnerId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    required this.createdAt,
    required this.isCustomItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      menuItemId: json['menu_item_id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      totalPrice: json['total_price']?.toString() ?? '0.00',
      specialInstructions: json['special_instructions'],
      createdAt: json['created_at'] ?? '',
      isCustomItem: json['is_custom_item'] ?? 0,
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
      'created_at': createdAt,
      'is_custom_item': isCustomItem,
    };
  }

  // Convert API OrderItem to local order item format
  Map<String, dynamic> toLocalOrderItem() {
    return {
      'id': menuItemId,
      'item_name': itemName,
      'quantity': quantity,
      'price': double.tryParse(unitPrice) ?? 0.0,
      'total_price': double.tryParse(totalPrice) ?? 0.0,
      'category': '',
      'description': specialInstructions ?? '',
      'is_vegetarian': false,
      'is_featured': false,
    };
  }
}