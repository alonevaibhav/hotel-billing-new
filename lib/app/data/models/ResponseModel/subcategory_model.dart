class MenuItemResponse {
  final String message;
  final bool success;
  final List<MenuItem> data;
  final List<dynamic> errors;

  MenuItemResponse({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) {
    return MenuItemResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      'errors': errors,
    };
  }
}

class MenuItem {
  final int id;
  final int hotelOwnerId;
  final String itemName;
  final String? description;
  final String? category;
  final int menuCategoryId;
  final String? imageUrl;
  final String price;
  final int preparationTime;
  final int isActive;
  final int isFeatured;
  final int isVegetarian;
  final int displayOrder;
  final String createdAt;
  final String updatedAt;
  final String menuCode;
  final int isAvailable;
  final String spiceLevel;
  final String categoryDisplayName;

  MenuItem({
    required this.id,
    required this.hotelOwnerId,
    required this.itemName,
    this.description,
    this.category,
    required this.menuCategoryId,
    this.imageUrl,
    required this.price,
    required this.preparationTime,
    required this.isActive,
    required this.isFeatured,
    required this.isVegetarian,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.menuCode,
    required this.isAvailable,
    required this.spiceLevel,
    required this.categoryDisplayName,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      description: json['description'],
      category: json['category'],
      menuCategoryId: json['menu_category_id'] ?? 0,
      imageUrl: json['image_url'],
      price: json['price']?.toString() ?? '0.00',
      preparationTime: json['preparation_time'] ?? 0,
      isActive: json['is_active'] ?? 0,
      isFeatured: json['is_featured'] ?? 0,
      isVegetarian: json['is_vegetarian'] ?? 0,
      displayOrder: json['display_order'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      menuCode: json['menu_code']?.toString() ?? '',
      isAvailable: json['is_available'] ?? 0,
      spiceLevel: json['spice_level'] ?? 'medium',
      categoryDisplayName: json['category_display_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_owner_id': hotelOwnerId,
      'item_name': itemName,
      'description': description,
      'category': category,
      'menu_category_id': menuCategoryId,
      'image_url': imageUrl,
      'price': price,
      'preparation_time': preparationTime,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_vegetarian': isVegetarian,
      'display_order': displayOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'menu_code': menuCode,
      'is_available': isAvailable,
      'spice_level': spiceLevel,
      'category_display_name': categoryDisplayName,
    };
  }
}