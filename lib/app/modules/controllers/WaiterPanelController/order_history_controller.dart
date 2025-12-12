// controllers/order_history_controller.dart

import 'package:get/get.dart';
import '../../../data/models/ResponseModel/order_history_model.dart';
import '../../../data/repositories/order_history_repository.dart';

class OrderHistoryController extends GetxController {
  final _repository = OrderRepository();

  // Observables
  final RxBool isLoading = false.obs;
  final RxList<Order> orders = <Order>[].obs;
  final RxInt totalOrders = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // ApiService returns ApiResponse<OrderHistoryResponse>
      final response = await _repository.getOrderHistory();

      if (response.success && response.data != null) {
        // Access the nested data from OrderHistoryResponse
        orders.value = response.data!.data.orders;
        totalOrders.value = response.data!.data.total;
        totalPages.value = response.data!.data.pages;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch orders';
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch order history: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshOrders() {
    fetchOrderHistory();
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return '0xFF4CAF50';
      case 'pending':
        return '0xFFFFA726';
      case 'cancelled':
        return '0xFFEF5350';
      default:
        return '0xFF90A4AE';
    }
  }

  String getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return '💵';
      case 'card':
        return '💳';
      case 'upi':
        return '📱';
      case 'pending':
        return '⏳';
      default:
        return '💰';
    }
  }
}