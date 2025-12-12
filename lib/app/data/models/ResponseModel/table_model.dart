// table_response_model.dart

class TableResponseModel {
  final String message;
  final bool success;
  final TableData? data;
  final List<dynamic> errors;

  TableResponseModel({
    required this.message,
    required this.success,
    this.data,
    required this.errors,
  });

  factory TableResponseModel.fromJson(Map<String, dynamic> json) {
    return TableResponseModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: json['data'] != null ? TableData.fromJson(json['data']) : null,
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}

class TableData {
  final List<TableInfo> tables;
  final int total;
  final int pages;
  final AllocationInfo? allocationInfo;

  TableData({
    required this.tables,
    required this.total,
    required this.pages,
    this.allocationInfo,
  });

  factory TableData.fromJson(Map<String, dynamic> json) {
    return TableData(
      tables: (json['tables'] as List<dynamic>?)
          ?.map((e) => TableInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      allocationInfo: json['allocationInfo'] != null
          ? AllocationInfo.fromJson(json['allocationInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tables': tables.map((e) => e.toJson()).toList(),
      'total': total,
      'pages': pages,
      'allocationInfo': allocationInfo?.toJson(),
    };
  }
}

class TableInfo {
  final Table table;
  final CurrentOrder? currentOrder;
  final String areaName;

  TableInfo({
    required this.table,
    this.currentOrder,
    required this.areaName,
  });

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      table: Table.fromJson(json['table']),
      currentOrder: json['current_order'] != null
          ? CurrentOrder.fromJson(json['current_order'])
          : null,
      areaName: json['area_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table': table.toJson(),
      'current_order': currentOrder?.toJson(),
      'area_name': areaName,
    };
  }
}

class Table {
  final int id;
  final int hotelOwnerId;
  final int tableAreaId;
  final String tableNumber;
  final String tableType;
  final int capacity;
  final String status;
  final String? description;
  final String? location;
  final String createdAt;
  final String updatedAt;

  Table({
    required this.id,
    required this.hotelOwnerId,
    required this.tableAreaId,
    required this.tableNumber,
    required this.tableType,
    required this.capacity,
    required this.status,
    this.description,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      tableAreaId: json['table_area_id'] ?? 0,
      tableNumber: json['table_number'] ?? '',
      tableType: json['table_type'] ?? '',
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? '',
      description: json['description'],
      location: json['location'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_owner_id': hotelOwnerId,
      'table_area_id': tableAreaId,
      'table_number': tableNumber,
      'table_type': tableType,
      'capacity': capacity,
      'status': status,
      'description': description,
      'location': location,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CurrentOrder {
  final int orderId;
  final String customerName;
  final String status;
  final String createdAt;
  final num totalAmount; // Changed from int to num to handle both int and double

  CurrentOrder({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
  });

  factory CurrentOrder.fromJson(Map<String, dynamic> json) {
    return CurrentOrder(
      orderId: json['order_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      totalAmount: json['total_amount'] ?? 0, // Handles both int and double
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_name': customerName,
      'status': status,
      'created_at': createdAt,
      'total_amount': totalAmount,
    };
  }
}

class AllocationInfo {
  final int allocated;
  final int current;
  final int remaining;
  final int percentage;

  AllocationInfo({
    required this.allocated,
    required this.current,
    required this.remaining,
    required this.percentage,
  });

  factory AllocationInfo.fromJson(Map<String, dynamic> json) {
    return AllocationInfo(
      allocated: json['allocated'] ?? 0,
      current: json['current'] ?? 0,
      remaining: json['remaining'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allocated': allocated,
      'current': current,
      'remaining': remaining,
      'percentage': percentage,
    };
  }
}