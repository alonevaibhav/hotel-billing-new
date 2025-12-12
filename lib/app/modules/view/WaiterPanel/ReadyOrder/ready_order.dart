import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../data/models/ResponseModel/ready_order_model.dart';
import '../../../controllers/WaiterPanelController/ready_order_controller.dart';

class ReadyOrder extends StatelessWidget {
  const ReadyOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = 0.9;
    final controller = Get.put(ReadyOrderController(), permanent: true);

    controller.fetchReadyOrders();


    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshOrders();
                },
                child: Obx(() {
                  // 1. Loading State
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // 2. Error State
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        // Ensures retry button is accessible on small screens
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[300],
                            ),
                            const Gap(16),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(16),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchReadyOrders(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 3. Empty State
                  if (controller.groupedOrders.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        // Ensures pull-to-refresh works even in empty state
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.room_service_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const Gap(16),
                            const Text(
                              'No orders ready to serve',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 4. Success State
                  // Renders your existing list builder
                  return buildOrdersList(controller, scaleFactor);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrdersList(ReadyOrderController controller, double scaleFactor) {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: (20 * scaleFactor).w,
            vertical: (16 * scaleFactor).h,
          ),
          itemCount: controller.groupedOrders.length,
          itemBuilder: (context, index) {
            final groupedOrder = controller.groupedOrders[index];
            return buildOrderCard(
                context, controller, groupedOrder, index, scaleFactor);
          },
        ));
  }

  Widget buildOrderCard(BuildContext context, ReadyOrderController controller,
      GroupedOrder groupedOrder, int index, double scaleFactor) {
    final items = groupedOrder.items;
    final totalAmount = groupedOrder.totalAmount;
    final totalItems = groupedOrder.totalItems;

    return Obx(() {
      final isServing = controller.isOrderServing(groupedOrder.orderId);

      return Container(
        margin: EdgeInsets.only(bottom: (16 * scaleFactor).h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular((12 * scaleFactor).r),
          border: Border.all(
            color: isServing
                ? Colors.orange.withOpacity(0.5)
                : Colors.green.withOpacity(0.3),
            width: isServing ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Container(
              padding: EdgeInsets.all((16 * scaleFactor).w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order no. ${groupedOrder.billNumber}',
                          style: GoogleFonts.inter(
                            fontSize: (16 * scaleFactor).sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Gap((4 * scaleFactor).h),
                        Text(
                          groupedOrder.customerName,
                          style: GoogleFonts.inter(
                            fontSize: (13 * scaleFactor).sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      buildInfoChip('Table ${groupedOrder.tableNumber}',
                          Icons.chair, scaleFactor),
                    ],
                  ),
                ],
              ),
            ),

            // Items Summary
            Container(
              padding: EdgeInsets.symmetric(horizontal: (16 * scaleFactor).w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready Items',
                    style: GoogleFonts.inter(
                      fontSize: (14 * scaleFactor).sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Gap((8 * scaleFactor).h),
                  Obx(() {
                    final isExpanded = controller.expandedOrders
                        .contains(groupedOrder.orderId);
                    final itemsToShow =
                        isExpanded ? items : items.take(2).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...itemsToShow
                            .map((item) => buildItemSummary(item, scaleFactor)),
                        if (items.length > 2) ...[
                          Gap((4 * scaleFactor).h),
                          GestureDetector(
                            onTap: () => controller
                                .toggleOrderExpansion(groupedOrder.orderId),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: (4 * scaleFactor).h),
                              child: Row(
                                children: [
                                  Text(
                                    isExpanded
                                        ? 'Show less'
                                        : '+${items.length - 2} more items',
                                    style: GoogleFonts.inter(
                                      fontSize: (12 * scaleFactor).sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[500],
                                    ),
                                  ),
                                  Gap((4 * scaleFactor).w),
                                  Icon(
                                    isExpanded
                                        ? PhosphorIcons.caretUp(
                                            PhosphorIconsStyle.regular)
                                        : PhosphorIcons.caretDown(
                                            PhosphorIconsStyle.regular),
                                    size: (12 * scaleFactor).sp,
                                    color: Colors.blue[500],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),

            Gap((16 * scaleFactor).h),

            // Order Summary and Actions
            Container(
              padding: EdgeInsets.all((16 * scaleFactor).w),
              decoration: BoxDecoration(
                color: isServing ? Colors.orange[50] : Colors.green[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular((12 * scaleFactor).r),
                  bottomRight: Radius.circular((12 * scaleFactor).r),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items: $totalItems',
                        style: GoogleFonts.inter(
                          fontSize: (14 * scaleFactor).sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        controller.formatCurrency(totalAmount),
                        style: GoogleFonts.inter(
                          fontSize: (16 * scaleFactor).sp,
                          fontWeight: FontWeight.w700,
                          color: isServing
                              ? Colors.orange[600]
                              : Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                  Gap((16 * scaleFactor).h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isServing
                              ? null
                              : () => _showMarkAsServedDialog(context,
                                  controller, groupedOrder, scaleFactor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isServing ? Colors.grey[400] : Colors.blue[500],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[500],
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular((8 * scaleFactor).r),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: (12 * scaleFactor).h),
                          ),
                          child: isServing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: (16 * scaleFactor).sp,
                                      height: (16 * scaleFactor).sp,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                    Gap((8 * scaleFactor).w),
                                    Text(
                                      'Marking as Served...',
                                      style: GoogleFonts.inter(
                                        fontSize: (13 * scaleFactor).sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIcons.bowlFood(
                                          PhosphorIconsStyle.bold),
                                      size: (16 * scaleFactor).sp,
                                    ),
                                    Gap((6 * scaleFactor).w),
                                    Text(
                                      'Mark as Served',
                                      style: GoogleFonts.inter(
                                        fontSize: (13 * scaleFactor).sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showMarkAsServedDialog(
    BuildContext context,
    ReadyOrderController controller,
    GroupedOrder order,
    double scaleFactor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((12 * scaleFactor).r),
          ),
          title: Row(
            children: [
              Icon(
                PhosphorIcons.bowlFood(PhosphorIconsStyle.bold),
                color: Colors.blue[500],
                size: (24 * scaleFactor).sp,
              ),
              Gap((8 * scaleFactor).w),
              Text(
                'Mark as Served',
                style: GoogleFonts.inter(
                  fontSize: (18 * scaleFactor).sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mark all items for Table ${order.tableNumber} as served?',
                style: GoogleFonts.inter(
                  fontSize: (14 * scaleFactor).sp,
                  color: Colors.grey[700],
                ),
              ),
              Gap((12 * scaleFactor).h),
              Container(
                padding: EdgeInsets.all((12 * scaleFactor).w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: GoogleFonts.inter(
                            fontSize: (13 * scaleFactor).sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${order.totalItems}',
                          style: GoogleFonts.inter(
                            fontSize: (13 * scaleFactor).sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    Gap((4 * scaleFactor).h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Total:',
                          style: GoogleFonts.inter(
                            fontSize: (13 * scaleFactor).sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          controller.formatCurrency(order.totalAmount),
                          style: GoogleFonts.inter(
                            fontSize: (13 * scaleFactor).sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: (14 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.markOrderAsServed(order, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: (20 * scaleFactor).w,
                  vertical: (10 * scaleFactor).h,
                ),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.inter(
                  fontSize: (14 * scaleFactor).sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildItemSummary(ReadyOrderItem item, double scaleFactor) {
    // Default to vegetarian if not specified in model
    final isVegetarian =
        true; // You can add this field to ReadyOrderItem model if needed

    return Padding(
      padding: EdgeInsets.only(bottom: (6 * scaleFactor).h),
      child: Row(
        children: [
          Container(
            width: (12 * scaleFactor).w,
            height: (12 * scaleFactor).w,
            decoration: BoxDecoration(
              border: Border.all(
                color: isVegetarian ? Colors.green : Colors.red,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular((2 * scaleFactor).r),
            ),
            child: Center(
              child: Container(
                width: (4 * scaleFactor).w,
                height: (4 * scaleFactor).w,
                decoration: BoxDecoration(
                  color: isVegetarian ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular((1 * scaleFactor).r),
                ),
              ),
            ),
          ),
          Gap((8 * scaleFactor).w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: GoogleFonts.inter(
                    fontSize: (13 * scaleFactor).sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.specialInstructions != null &&
                    item.specialInstructions!.isNotEmpty) ...[
                  Gap((2 * scaleFactor).h),
                  Text(
                    item.specialInstructions!,
                    style: GoogleFonts.inter(
                      fontSize: (11 * scaleFactor).sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: (6 * scaleFactor).w, vertical: (2 * scaleFactor).h),
            decoration: BoxDecoration(
              color: Colors.blue[500],
              borderRadius: BorderRadius.circular((3 * scaleFactor).r),
            ),
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.inter(
                fontSize: (11 * scaleFactor).sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoChip(String label, IconData icon, double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (10 * scaleFactor).w,
        vertical: (6 * scaleFactor).h,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular((6 * scaleFactor).r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: (14 * scaleFactor).sp,
            color: Colors.blue[700],
          ),
          Gap((4 * scaleFactor).w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: (12 * scaleFactor).sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
