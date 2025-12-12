// lib/app/data/models/category_model.dart

class CategoryResponse {
  final String message;
  final bool success;
  final List<Category> data;
  final List<dynamic> errors;

  CategoryResponse({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }
}

class Category {
  final int id;
  final int hotelOwnerId;
  final String categoryName;
  final int isActive;
  final int? displayOrder;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.hotelOwnerId,
    required this.categoryName,
    required this.isActive,
    this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      isActive: json['is_active'] ?? 0,
      displayOrder: json['display_order'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_owner_id': hotelOwnerId,
      'category_name': categoryName,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $categoryName, isActive: $isActive)';
  }
}