// views/order_history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../data/models/ResponseModel/order_history_model.dart';
import '../../../../../state/app_initial_state.dart';
import '../../../../controllers/WaiterPanelController/order_history_controller.dart';

class ChefOrderHistoryView extends StatelessWidget {
  const ChefOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(controller),
      body: AsyncStateBuilder<OrderHistoryController>(
        controller: controller,
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        observeData: [controller.orders],
        isEmpty: (ctrl) => ctrl.orders.isEmpty,
        onRetry: controller.refreshOrders,
        onRefresh: controller.fetchOrderHistory,
        emptyStateText: 'No order history available',
        builder: (ctrl) => _buildOrdersList(ctrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(OrderHistoryController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Order History',
        style: TextStyle(
          color: Color(0xFF1A1D2E),
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF667EEA)),
            onPressed: controller.refreshOrders,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrderHistoryController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) {
        final order = controller.orders[index];
        return _buildOrderCard(order, controller);
      },
    );
  }

  Widget _buildOrderCard(Order order, OrderHistoryController controller) {
    final statusColor = Color(int.parse(controller.getStatusColor(order.status)));
    final paymentIcon = controller.getPaymentMethodIcon(order.paymentMethod);
    final dateTime = DateTime.parse(order.createdAt);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to order details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order, statusColor, paymentIcon),
                const SizedBox(height: 14),
                _buildInfoRow(order),
                const SizedBox(height: 14),
                _buildDateTime(formattedDate),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
                _buildAmountsSection(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order, Color statusColor, String paymentIcon) {
    return Row(
      children: [
        // Bill Number
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5568D3), width: 1),
          ),
          child: Text(
            order.billNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
          ),
          child: Text(
            order.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Spacer(),
        // Payment Method
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Text(
            paymentIcon,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(Order order) {
    return Row(
      children: [
        _buildInfoChip(
          Icons.table_restaurant_rounded,
          'Table ${order.tableNumber}',
          const Color(0xFF667EEA),
        ),
        const SizedBox(width: 10),
        _buildInfoChip(
          Icons.people_outline_rounded,
          '${order.capacity} Seats',
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime(String formattedDate) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: const Icon(
            Icons.access_time_rounded,
            size: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formattedDate,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountsSection(Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          _buildAmountRow('Subtotal', order.totalAmount, false),
          const SizedBox(height: 10),
          _buildAmountRow('Tax', order.taxAmount, false),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
          _buildAmountRow('Total Amount', order.finalAmount, true),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, dynamic amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? const Color(0xFF1A1D2E) : const Color(0xFF6B7280),
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          '₹$amount',
          style: TextStyle(
            color: isTotal ? const Color(0xFF667EEA) : const Color(0xFF1A1D2E),
            fontSize: isTotal ? 17 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}