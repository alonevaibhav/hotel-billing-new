// lib/app/modules/waiter_panel/services/menu_item_service.dart

import 'dart:developer' as developer;
import '../../data/models/ResponseModel/category_model.dart';
import '../../data/models/ResponseModel/subcategory_model.dart';

/// Service for menu item business logic
class MenuItemService {
  /// Extract active categories from API response
  static List<Category> getActiveCategories(CategoryResponse response) {
    return response.data.where((cat) => cat.isActive == 1).toList();
  }

  /// Build category names list with "All" option
  static List<String> buildCategoryNames(List<Category> categories) {
    final names = categories.map((cat) => cat.categoryName).toList()..sort();
    return ['All', ...names];
  }

  /// Process menu item to local format
  static Map<String, dynamic> processMenuItem(
      MenuItem item,
      String categoryName,
      ) {
    return {
      'id': item.id,
      'hotel_owner_id': item.hotelOwnerId,
      'item_name': item.itemName,
      'description': item.description,
      'category_display': categoryName,
      'menu_category_id': item.menuCategoryId,
      'image_url': item.imageUrl,
      'price': item.price,
      'preparation_time': item.preparationTime,
      'is_active': item.isActive,
      'is_featured': item.isFeatured,
      'is_vegetarian': item.isVegetarian,
      'display_order': item.displayOrder,
      'menu_code': item.menuCode,
      'is_available': item.isAvailable,
      'spice_level': item.spiceLevel,
      'quantity': 0,
    };
  }

  /// Filter items based on category, search, and filters
  static List<Map<String, dynamic>> filterItems({
    required List<Map<String, dynamic>> allItems,
    required String selectedCategory,
    required String searchQuery,
    required List<String> activeFilters,
  }) {
    if (allItems.isEmpty) return [];

    var filtered = allItems.where((item) {
      // Category filter
      bool matchesCategory = selectedCategory == 'All' ||
          item['category_display'] == selectedCategory;

      // Search filter
      bool matchesSearch = searchQuery.isEmpty ||
          (item['item_name'] as String)
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      // Active filters
      bool matchesFilters = true;
      if (activeFilters.contains('Vegetarian')) {
        matchesFilters = matchesFilters && (item['is_vegetarian'] == 1);
      }
      if (activeFilters.contains('Featured')) {
        matchesFilters = matchesFilters && (item['is_featured'] == 1);
      }

      return matchesCategory && matchesSearch && matchesFilters;
    }).toList();

    // Sort alphabetically
    filtered.sort((a, b) =>
        (a['item_name'] as String).compareTo(b['item_name'] as String));

    return filtered;
  }

  /// Sort items alphabetically by name
  static void sortItemsByName(List<Map<String, dynamic>> items) {
    items.sort((a, b) =>
        (a['item_name'] as String).compareTo(b['item_name'] as String));
  }

  /// Get items with quantity > 0
  static List<Map<String, dynamic>> getSelectedItems(
      List<Map<String, dynamic>> allItems,
      ) {
    return allItems.where((item) => (item['quantity'] as int) > 0).toList();
  }

  /// Calculate total quantity of selected items
  static int calculateTotalQuantity(List<Map<String, dynamic>> selectedItems) {
    return selectedItems.fold<int>(
      0,
          (sum, item) => sum + (item['quantity'] as int),
    );
  }

  /// Calculate total price of selected items
  static double calculateTotalPrice(List<Map<String, dynamic>> selectedItems) {
    return selectedItems.fold<double>(0.0, (sum, item) {
      final price = double.parse(item['price'].toString());
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
  }

  /// Create order item from menu item
  static Map<String, dynamic> createOrderItem(Map<String, dynamic> menuItem) {
    final price = double.parse(menuItem['price'].toString());
    final quantity = menuItem['quantity'] as int;

    return {
      'id': menuItem['id'],
      'item_name': menuItem['item_name'],
      'price': price,
      'quantity': quantity,
      'category': menuItem['category_display'],
      'description': menuItem['description'] ?? '',
      'preparation_time': menuItem['preparation_time'] ?? 0,
      'is_vegetarian': menuItem['is_vegetarian'] ?? 0,
      'is_featured': menuItem['is_featured'] ?? 0,
      'total_price': price * quantity,
      'added_at': DateTime.now().toIso8601String(),
    };
  }

  /// Reset quantity for all items
  static void resetItemQuantities(List<Map<String, dynamic>> items) {
    for (var item in items) {
      item['quantity'] = 0;
    }
  }

  /// Check if item is available for ordering
  static bool isItemAvailable(MenuItem item) {
    return item.isActive == 1 && item.isAvailable == 1;
  }

  /// Process menu items from API response
  static List<Map<String, dynamic>> processMenuItems(
      MenuItemResponse response,
      String categoryName,
      ) {
    return response.data
        .where((item) => isItemAvailable(item))
        .map((item) => processMenuItem(item, categoryName))
        .toList();
  }
}