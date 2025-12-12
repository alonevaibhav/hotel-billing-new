// // lib/app/data/repositories/ready_order_repository.dart
//
// import '../../core/constants/api_constant.dart';
// import '../../core/services/api_service.dart';
// import '../models/ResponseModel/ready_order_model.dart';
//
// class ReadyOrderRepository {
//
//   /// Fetch ready to serve orders
//   Future<ApiResponse<ReadyOrderResponse>> getReadyToServeOrders() async {
//     try {
//       final response = await ApiService.get<ReadyOrderResponse>(
//         endpoint: ApiConstants.waiterGetReadyToServe,
//         fromJson: (json) => ReadyOrderResponse.fromJson(json),
//         includeToken: true,
//       );
//
//       return response;
//     } catch (e) {
//       throw Exception('Failed to fetch ready orders: ${e.toString()}');
//     }
//   }
//
//
// }

// lib/app/data/repositories/ready_order_repository.dart
import 'package:http/http.dart';

import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../models/ResponseModel/ready_order_model.dart';

class ReadyOrderRepository {

  /// Fetch ready to serve orders
  Future<ApiResponse<ReadyOrderResponse>> getReadyToServeOrders() async {
    try {
      final response = await ApiService.get<ReadyOrderResponse>(
        endpoint: ApiConstants.waiterGetReadyToServe,
        fromJson: (json) => ReadyOrderResponse.fromJson(json),
        includeToken: true,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to fetch ready orders: ${e.toString()}');
    }
  }

  /// Update item status to served
  Future<ApiResponse<Map<String, dynamic>>> updateItemStatus({
    required int orderId,
    required int itemId,
    required String itemStatus,
  }) async {
    try {
      final response = await ApiService.patch<Map<String, dynamic>>(
        endpoint: ApiConstants.waiterPatchOrderUpdate(orderId, itemId),
        body: {
          'item_status': itemStatus,
        },
        fromJson: (json) => json as Map<String, dynamic>,
        includeToken: true,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update item status: ${e.toString()}');
    }
  }

  /// Mark single item as served
  Future<ApiResponse<Map<String, dynamic>>> markItemAsServed({
    required int orderId,
    required int itemId,
  }) async {
    return await updateItemStatus(
      orderId: orderId,
      itemId: itemId,
      itemStatus: 'served',
    );
  }

  /// Mark all items in an order as served
  Future<List<ApiResponse<Map<String, dynamic>>>> markOrderItemsAsServed({
    required int orderId,
    required List<int> itemIds,
  }) async {
    final List<ApiResponse<Map<String, dynamic>>> responses = [];

    for (final itemId in itemIds) {
      try {
        final response = await markItemAsServed(
          orderId: orderId,
          itemId: itemId,
        );
        responses.add(response);
      } catch (e) {
        // Continue with other items even if one fails
        responses.add(ApiResponse<Map<String, dynamic>>(
          success: false,
          errorMessage: e.toString(), statusCode: 200,
        ));
      }
    }

    return responses;
  }
}