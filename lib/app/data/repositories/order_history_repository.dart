// repositories/order_repository.dart

import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../models/ResponseModel/order_history_model.dart';

class OrderRepository {
  // Optimized: Direct method calls without instance

  Future<ApiResponse<OrderHistoryResponse>> getOrderHistory() async {
    try {
      // ApiService.get returns ApiResponse<T>, not the model directly
      final response = await ApiService.get<OrderHistoryResponse>(
        endpoint: ApiConstants.waiterGetHistory,
        fromJson: (json) => OrderHistoryResponse.fromJson(json),
        includeToken: true,
      );
      return response;
    } catch (e) {
      // Return error response instead of rethrowing
      return ApiResponse<OrderHistoryResponse>(
        success: false,
        errorMessage: e.toString(),
        statusCode: -1,
      );
    }
  }
}