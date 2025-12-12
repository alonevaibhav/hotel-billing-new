// models/order_model.dart

class OrderHistoryResponse {
  final String message;
  final bool success;
  final OrderData data;
  final List<dynamic> errors;

  OrderHistoryResponse({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: OrderData.fromJson(json['data'] ?? {}),
      errors: json['errors'] ?? [],
    );
  }
}

class OrderData {
  final List<Order> orders;
  final int total;
  final int pages;

  OrderData({
    required this.orders,
    required this.total,
    required this.pages,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orders: (json['orders'] as List?)
          ?.map((order) => Order.fromJson(order))
          .toList() ??
          [],
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }
}

class Order {
  final int id;
  final String billNumber;
  final String? customerName;
  final String? customerPhone;
  final String status;
  final String paymentMethod;
  final String totalAmount;
  final String taxAmount;
  final String discount;
  final String finalAmount;
  final String? specialInstructions;
  final String createdAt;
  final String updatedAt;
  final int hotelTableId;
  final int hotelOwnerId;
  final int counterBilling;
  final String tableNumber;
  final String tableType;
  final int capacity;
  final String? tableLocation;
  final int includeGst;
  final String gstPercentage;
  final String cgstPercentage;
  final String sgstPercentage;

  Order({
    required this.id,
    required this.billNumber,
    this.customerName,
    this.customerPhone,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.taxAmount,
    required this.discount,
    required this.finalAmount,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
    required this.hotelTableId,
    required this.hotelOwnerId,
    required this.counterBilling,
    required this.tableNumber,
    required this.tableType,
    required this.capacity,
    this.tableLocation,
    required this.includeGst,
    required this.gstPercentage,
    required this.cgstPercentage,
    required this.sgstPercentage,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      billNumber: json['bill_number'] ?? '',
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'pending',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      finalAmount: json['final_amount']?.toString() ?? '0.00',
      specialInstructions: json['special_instructions'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      hotelTableId: json['hotel_table_id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      counterBilling: json['counter_billing'] ?? 0,
      tableNumber: json['table_number'] ?? '',
      tableType: json['table_type'] ?? 'standard',
      capacity: json['capacity'] ?? 0,
      tableLocation: json['table_location'],
      includeGst: json['include_gst'] ?? 1,
      gstPercentage: json['gst_percentage']?.toString() ?? '0.00',
      cgstPercentage: json['cgst_percentage']?.toString() ?? '0.00',
      sgstPercentage: json['sgst_percentage']?.toString() ?? '0.00',
    );
  }
}