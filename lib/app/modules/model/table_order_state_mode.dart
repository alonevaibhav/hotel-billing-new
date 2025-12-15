// import 'dart:developer' as developer;
// import 'package:flutter/material.dart' hide Table;
// import 'package:get/get.dart';
//
// import 'froze_model.dart';
//
//
// class TableOrderState {
//   final int tableId;
//
//   // Observable lists and values
//   final orderItems = <Map<String, dynamic>>[].obs;
//   final frozenItems = <FrozenItem>[].obs;
//   final isMarkAsUrgent = false.obs;
//   final finalCheckoutTotal = 0.0.obs;
//   final isLoadingOrder = false.obs;
//   final hasLoadedOrder = false.obs;
//   final placedOrderId = Rxn<int>();
//
//   // Controllers
//   final fullNameController = TextEditingController();
//   final phoneController = TextEditingController();
//
//   TableOrderState({required this.tableId});
//
//   /// Dispose controllers
//   void dispose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//   }
//
//   /// Clear all state
//   void clear() {
//     fullNameController.clear();
//     phoneController.clear();
//     orderItems.clear();
//     frozenItems.clear();
//     finalCheckoutTotal.value = 0.0;
//     isMarkAsUrgent.value = false;
//     hasLoadedOrder.value = false;
//     placedOrderId.value = null;
//   }
//
//   /// Get frozen quantity for an item
//   int getFrozenQuantity(String itemId) {
//     return frozenItems
//         .firstWhereOrNull((item) => item.id == itemId)
//         ?.quantity ??
//         0;
//   }
//
//   /// Add or update frozen items
//   void addFrozenItems(List<Map<String, dynamic>> items) {
//     for (var item in items) {
//       final itemId = item['id'].toString();
//       final quantity = item['quantity'] as int;
//
//       final existingIndex = frozenItems.indexWhere((f) => f.id == itemId);
//
//       if (existingIndex >= 0) {
//         // Increase frozen quantity
//         final existing = frozenItems[existingIndex];
//         frozenItems[existingIndex] = FrozenItem(
//           id: existing.id,
//           name: existing.name,
//           quantity: existing.quantity + quantity,
//         );
//       } else {
//         // Add new frozen item
//         frozenItems.add(FrozenItem(
//           id: itemId,
//           name: item['item_name'],
//           quantity: quantity,
//         ));
//       }
//     }
//   }
//
//   /// Update total checkout amount
//   void updateTotal(double newTotal) {
//     finalCheckoutTotal.value = newTotal;
//   }
//
//   // Computed properties
//   bool get hasFrozenItems => frozenItems.isNotEmpty;
//
//   bool get isReorderScenario =>
//       placedOrderId.value != null && placedOrderId.value! > 0;
//
//   bool get hasItems => orderItems.isNotEmpty;
//
//   bool get isAvailableForNewOrder => !isLoadingOrder.value && hasItems;
//
//
//
//
// }


import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/WaiterPanelController/select_item_controller.dart';
import 'froze_model.dart';

class TableOrderState {
  final int tableId;

  // Observable lists and values
  final orderItems = <Map<String, dynamic>>[].obs;
  final frozenItems = <FrozenItem>[].obs;
  final isMarkAsUrgent = false.obs;
  final finalCheckoutTotal = 0.0.obs;
  final isLoadingOrder = false.obs;
  final hasLoadedOrder = false.obs;
  final placedOrderId = Rxn<int>();

  // Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  // 🆕 For auto-update
  Timer? _debounceTimer;

  TableOrderState({required this.tableId}) {
    // 🆕 Setup auto-update listeners
    fullNameController.addListener(_autoUpdateCustomerInfo);
    phoneController.addListener(_autoUpdateCustomerInfo);
  }

  // 🆕 Auto-update customer info after 2 seconds of typing
  void _autoUpdateCustomerInfo() {
    _debounceTimer?.cancel();

    // Only update if there's an existing order
    if (placedOrderId.value == null || placedOrderId.value! <= 0) return;

    // Only update if fields have content
    if (fullNameController.text.trim().isEmpty && phoneController.text.trim().isEmpty) return;

    _debounceTimer = Timer(const Duration(seconds: 2), () {
      Get.find<OrderManagementController>().updateCustomerInfo(
        placedOrderId.value!,
        fullNameController.text.trim(),
        phoneController.text.trim(),
      );
    });
  }

  /// Dispose controllers
  void dispose() {
    _debounceTimer?.cancel();
    fullNameController.removeListener(_autoUpdateCustomerInfo);
    phoneController.removeListener(_autoUpdateCustomerInfo);
    fullNameController.dispose();
    phoneController.dispose();
  }

  /// Clear all state
  void clear() {
    _debounceTimer?.cancel();
    fullNameController.clear();
    phoneController.clear();
    orderItems.clear();
    frozenItems.clear();
    finalCheckoutTotal.value = 0.0;
    isMarkAsUrgent.value = false;
    hasLoadedOrder.value = false;
    placedOrderId.value = null;
  }

  /// Get frozen quantity for an item
  int getFrozenQuantity(String itemId) {
    return frozenItems
        .firstWhereOrNull((item) => item.id == itemId)
        ?.quantity ??
        0;
  }

  /// Add or update frozen items
  void addFrozenItems(List<Map<String, dynamic>> items) {
    for (var item in items) {
      final itemId = item['id'].toString();
      final quantity = item['quantity'] as int;

      final existingIndex = frozenItems.indexWhere((f) => f.id == itemId);

      if (existingIndex >= 0) {
        // Increase frozen quantity
        final existing = frozenItems[existingIndex];
        frozenItems[existingIndex] = FrozenItem(
          id: existing.id,
          name: existing.name,
          quantity: existing.quantity + quantity,
        );
      } else {
        // Add new frozen item
        frozenItems.add(FrozenItem(
          id: itemId,
          name: item['item_name'],
          quantity: quantity,
        ));
      }
    }
  }

  /// Update total checkout amount
  void updateTotal(double newTotal) {
    finalCheckoutTotal.value = newTotal;
  }

  // Computed properties
  bool get hasFrozenItems => frozenItems.isNotEmpty;

  bool get isReorderScenario =>
      placedOrderId.value != null && placedOrderId.value! > 0;

  bool get hasItems => orderItems.isNotEmpty;

  bool get isAvailableForNewOrder => !isLoadingOrder.value && hasItems;
}
