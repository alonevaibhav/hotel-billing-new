
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../core/utils/snakbar_utils.dart';
import '../../../data/models/ResponseModel/category_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../route/app_routes.dart';
import '../../controllers/WaiterPanelController/select_item_controller.dart';
import '../../model/table_order_state_mode.dart';
import '../../service/menu_item_service.dart';

class AddItemsController extends GetxController {
  // Dependencies
  final MenuRepository _menuRepository = MenuRepository();

  // Search functionality
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Categories
  final categories = <String>[].obs;
  final categoryObjects = <Category>[].obs;
  final selectedCategory = 'All'.obs;
  final selectedCategoryId = Rxn<int>();
  final activeFilters = <String>[].obs;

  // Menu items
  final filteredItems = <Map<String, dynamic>>[].obs;
  final allItems = <Map<String, dynamic>>[].obs;
  final selectedItems = <Map<String, dynamic>>[].obs;

  // Loading & Error states
  final isLoading = false.obs;
  final isLoadingItems = false.obs;
  final errorMessage = ''.obs;

  // Table context
  final currentTable = Rxn<Map<String, dynamic>>();
  final currentTableId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    loadCategories();
    developer.log('AddItemsController initialized');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ==================== INITIALIZATION ====================

  void setTableContext(Map<String, dynamic>? table) {
    currentTable.value = table;
    currentTableId.value = table?['id'] ?? 0;
    developer.log('Table context set: ${table?['tableNumber']}');
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applyFilters();
    });
  }

  // ==================== ERROR HANDLING ====================

  void _setError(String message) {
    errorMessage.value = message;
    developer.log('Error set: $message', name: 'ADD_ITEMS');
  }

  void _clearError() {
    errorMessage.value = '';
  }

  // ==================== CATEGORY MANAGEMENT ====================

  /// Load categories from API
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      _clearError();
      developer.log('Loading categories...', name: 'ADD_ITEMS');

      final response = await _menuRepository.getCategories();

      if (response.success && response.data.isNotEmpty) {
        categoryObjects.value = MenuItemService.getActiveCategories(response);
        categories.value = MenuItemService.buildCategoryNames(categoryObjects);

        developer.log('Categories loaded: ${categories.length}', name: 'ADD_ITEMS');

        // Load all items initially
        await _loadAllItems();
      } else {
        _setError('No categories available');
      }
    } catch (e) {
      developer.log('Error loading categories: $e', name: 'ADD_ITEMS');
      _setError('Failed to load menu categories. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }



  /// Select category
  Future<void> selectCategory(String categoryName) async {
    if (selectedCategory.value == categoryName) return;

    selectedCategory.value = categoryName;
    developer.log('Category selected: $categoryName', name: 'ADD_ITEMS');

    if (categoryName == 'All') {
      selectedCategoryId.value = null;
      _applyFilters();
      return;
    }

    final category = categoryObjects.firstWhereOrNull((cat) => cat.categoryName == categoryName,);

    if (category == null) {
      developer.log('Category not found: $categoryName', name: 'ADD_ITEMS');
      return;
    }

    selectedCategoryId.value = category.id;

    // Check if items already loaded
    final hasItems = allItems.any(
          (item) => item['menu_category_id'] == category.id,
    );

    if (!hasItems) {
      await _loadItemsForCategory(category.id, categoryName);
    }

    _applyFilters();
  }

  // ==================== ITEM LOADING ====================

  /// Load all items across categories
  Future<void> _loadAllItems() async {
    try {
      allItems.clear();

      for (var category in categoryObjects) {
        await _loadItemsForCategory(category.id, category.categoryName);
      }

      MenuItemService.sortItemsByName(allItems);
      _applyFilters();

      developer.log('All items loaded: ${allItems.length}', name: 'ADD_ITEMS');
    } catch (e) {
      developer.log('Error loading all items: $e', name: 'ADD_ITEMS');
      _setError('Failed to load menu items');
    }
  }

  /// Load items for specific category
  Future<void> _loadItemsForCategory(int categoryId, String categoryName) async {
    try {
      isLoadingItems.value = true;
      developer.log(
        'Loading items for: $categoryName (ID: $categoryId)',
        name: 'ADD_ITEMS',
      );

      final response = await _menuRepository.getMenuItemsByCategory(categoryId);

      if (response.success && response.data.isNotEmpty) {
        // Remove old items from this category
        allItems.removeWhere((item) => item['menu_category_id'] == categoryId);

        // Process and add new items
        final processedItems = MenuItemService.processMenuItems(
          response,
          categoryName,
        );

        allItems.addAll(processedItems);

        developer.log(
          'Loaded ${processedItems.length} items for $categoryName',
          name: 'ADD_ITEMS',
        );
      } else {
        developer.log('No items found for: $categoryName', name: 'ADD_ITEMS');
      }
    } catch (e) {
      developer.log(
        'Error loading items for $categoryName: $e',
        name: 'ADD_ITEMS',
      );
      if (Get.context != null) {
        SnackBarUtil.showError(
          Get.context!,
          'Failed to load items for $categoryName',
          title: 'Error',
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      isLoadingItems.value = false;
    }
  }

  // ==================== FILTERING ====================

  /// Apply all filters
  void _applyFilters() {
    filteredItems.value = MenuItemService.filterItems(
      allItems: allItems,
      selectedCategory: selectedCategory.value,
      searchQuery: searchQuery.value,
      activeFilters: activeFilters,
    );

    developer.log(
      'Filtered: ${filteredItems.length}/${allItems.length} items',
      name: 'ADD_ITEMS',
    );
  }

  /// Toggle filter option
  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
    _applyFilters();
    developer.log('Filter toggled: $filter', name: 'ADD_ITEMS');
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  // ==================== QUANTITY MANAGEMENT ====================

  /// Increment item quantity
  void incrementItemQuantity(Map<String, dynamic> item) {
    final index = allItems.indexWhere((el) => el['id'] == item['id']);
    if (index != -1) {
      allItems[index]['quantity'] = (allItems[index]['quantity'] as int) + 1;
      _updateSelectedItems();
      _applyFilters();
      developer.log('Incremented: ${item['item_name']}', name: 'ADD_ITEMS');
    }
  }

  /// Decrement item quantity
  void decrementItemQuantity(Map<String, dynamic> item) {
    final index = allItems.indexWhere((el) => el['id'] == item['id']);
    if (index != -1) {
      final currentQty = allItems[index]['quantity'] as int;
      if (currentQty > 0) {
        allItems[index]['quantity'] = currentQty - 1;
        _updateSelectedItems();
        _applyFilters();
        developer.log('Decremented: ${item['item_name']}', name: 'ADD_ITEMS');
      }
    }
  }

  void _updateSelectedItems() {
    selectedItems.value = MenuItemService.getSelectedItems(allItems);
  }

  // ==================== ADD TO TABLE ====================

  /// Add selected items to table order
  void addSelectedItemsToTable(BuildContext context) {
    if (selectedItems.isEmpty) {
      _showNoItemsWarning(context);
      return;
    }

    try {
      final tableId = currentTableId.value;
      final orderController = Get.find<OrderManagementController>();
      final tableState = orderController.getTableState(tableId);

      developer.log('=== ADDING ITEMS ===', name: 'ADD_ITEMS');
      developer.log('Total selected: ${selectedItems.length}', name: 'ADD_ITEMS');

      for (var menuItem in selectedItems) {
        final orderItem = MenuItemService.createOrderItem(menuItem);
        _mergeOrAddToOrder(tableState, orderItem);
      }

      _updateTableTotal(tableState);
      _showSuccessAndNavigateBack(context);
    } catch (e) {
      developer.log('Error adding items: $e', name: 'ADD_ITEMS');
      _showAddItemsError(context, e);
    }
  }

  void _mergeOrAddToOrder(
      TableOrderState tableState,
      Map<String, dynamic> orderItem,
      ) {
    final id = orderItem['id'];
    final existingIndex = tableState.orderItems.indexWhere((e) => e['id'] == id);

    if (existingIndex >= 0) {
      // Merge with existing item
      final existing = tableState.orderItems[existingIndex];
      final oldQty = existing['quantity'] as int;
      final newQty = oldQty + (orderItem['quantity'] as int);
      final price = existing['price'] as double;

      existing['quantity'] = newQty;
      existing['total_price'] = price * newQty;
      tableState.orderItems[existingIndex] = existing;

      developer.log(
        '✅ MERGED: ${orderItem['item_name']} - Old: $oldQty, New: $newQty',
        name: 'ADD_ITEMS',
      );
    } else {
      // Add new item
      tableState.orderItems.add(orderItem);
      developer.log(
        '✅ NEW: ${orderItem['item_name']} - Qty: ${orderItem['quantity']}',
        name: 'ADD_ITEMS',
      );
    }
  }

  void _updateTableTotal(TableOrderState tableState) {
    final total = tableState.orderItems.fold<double>(
      0.0,
          (sum, item) => sum + (item['total_price'] as double),
    );
    tableState.finalCheckoutTotal.value = total;
  }

  void _showSuccessAndNavigateBack(BuildContext context) {
    final tableNumber = currentTable.value?['tableNumber'] ?? currentTableId.value;
    final totalItems = MenuItemService.calculateTotalQuantity(selectedItems);

    developer.log(
      '✅ SUCCESS: Added $totalItems items to table $currentTableId',
      name: 'ADD_ITEMS',
    );

    SnackBarUtil.showSuccess(
      context,
      '$totalItems items added to Table $tableNumber',
      title: 'Items Added',
      duration: const Duration(seconds: 1),
    );

    clearAllSelections();
    NavigationService.goBack();
  }

  void _showNoItemsWarning(BuildContext context) {
    SnackBarUtil.showWarning(
      context,
      'Please select at least one item',
      title: 'No Items Selected',
      duration: const Duration(seconds: 1),
    );
  }

  void _showAddItemsError(BuildContext context, dynamic error) {
    SnackBarUtil.showError(
      context,
      'Failed to add items to order: $error',
      title: 'Error',
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  int get totalSelectedItems =>
      MenuItemService.calculateTotalQuantity(selectedItems);

  double get totalSelectedPrice =>
      MenuItemService.calculateTotalPrice(selectedItems);

  // ==================== UTILITIES ====================

  /// Clear all selections
  void clearAllSelections() {
    MenuItemService.resetItemQuantities(allItems);
    selectedItems.clear();
    _applyFilters();
    developer.log('All selections cleared', name: 'ADD_ITEMS');
  }

  /// Refresh categories (used by AsyncStateBuilder)
  Future<void> refreshCategories() async {
    _clearError();
    await loadCategories();
  }
}