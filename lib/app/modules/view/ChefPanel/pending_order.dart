//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hotelbilling/app/modules/view/ChefPanel/widgets/accept_order_widget.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import '../../controllers/ChefController/accept_order_controller.dart';
// import '../../../data/models/ResponseModel/pending_orders_model.dart';
//
//
// class AcceptOrder extends StatelessWidget {
//   const AcceptOrder({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final scaleFactor = 0.9;
//     final controller = Get.put(AcceptOrderController());
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Stack(
//         children: [
//           // Main Content
//           Column(
//             children: [
//               Expanded(
//                 child: buildOrdersList(controller, scaleFactor),
//               ),
//             ],
//           ),
//           // Rejection Dialog Overlay
//           Obx(() => controller.isRejectDialogVisible.value
//               ? buildRejectDialog(context, controller, scaleFactor)
//               : const SizedBox.shrink()),
//         ],
//       ),
//     );
//   }
//
//   Widget buildOrdersList(AcceptOrderController controller, double scaleFactor) {
//     return Obx(() {
//       // Show loading indicator
//       if (controller.isLoading.value && controller.ordersData.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 color: Colors.blue[500],
//                 strokeWidth: 3,
//               ),
//               Gap((16 * scaleFactor).h),
//               Text(
//                 'Loading orders...',
//                 style: GoogleFonts.inter(
//                   fontSize: (14 * scaleFactor).sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//
//       // Show error message if exists
//       if (controller.errorMessage.value.isNotEmpty ) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
//                 size: (64 * scaleFactor).sp,
//                 color: Colors.red[400],
//               ),
//               Gap((16 * scaleFactor).h),
//               Text(
//                 'Failed to load orders',
//                 style: GoogleFonts.inter(
//                   fontSize: (16 * scaleFactor).sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               Gap((8 * scaleFactor).h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: (40 * scaleFactor).w),
//                 child: Text(
//                   controller.errorMessage.value,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.inter(
//                     fontSize: (13 * scaleFactor).sp,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//               Gap((24 * scaleFactor).h),
//               ElevatedButton.icon(
//                 onPressed: () => controller.refreshOrders(),
//                 icon: Icon(
//                   PhosphorIcons.arrowClockwise(PhosphorIconsStyle.regular),
//                   size: (18 * scaleFactor).sp,
//                 ),
//                 label: Text(
//                   'Retry',
//                   style: GoogleFonts.inter(
//                     fontSize: (14 * scaleFactor).sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[500],
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: (24 * scaleFactor).w,
//                     vertical: (12 * scaleFactor).h,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular((8 * scaleFactor).r),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//
//       // Show empty state
//       if (controller.ordersData.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 PhosphorIcons.clipboard(PhosphorIconsStyle.regular),
//                 size: (64 * scaleFactor).sp,
//                 color: Colors.grey[400],
//               ),
//               Gap((16 * scaleFactor).h),
//               Text(
//                 'No pending orders',
//                 style: GoogleFonts.inter(
//                   fontSize: (16 * scaleFactor).sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               Gap((8 * scaleFactor).h),
//               Text(
//                 'New orders will appear here',
//                 style: GoogleFonts.inter(
//                   fontSize: (13 * scaleFactor).sp,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//
//       // Show orders list with pull to refresh
//       return RefreshIndicator(
//         onRefresh: () => controller.refreshOrders(),
//         color: Colors.blue[500],
//         child: ListView.builder(
//           padding: EdgeInsets.symmetric(
//             horizontal: (20 * scaleFactor).w,
//             vertical: (16 * scaleFactor).h,
//           ),
//           itemCount: controller.ordersData.length,
//           itemBuilder: (context, index) {
//             final order = controller.ordersData[index];
//             return buildOrderCard(context, controller, order, scaleFactor);
//           },
//         ),
//       );
//     });
//   }
//
//   Widget buildOrderCard(
//       BuildContext context,
//       AcceptOrderController controller,
//       GroupedOrder order,
//       double scaleFactor,
//       ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: (16 * scaleFactor).h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular((12 * scaleFactor).r),
//         border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Order Header
//           Container(
//             padding: EdgeInsets.all((16 * scaleFactor).w),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Order no. ${order.orderId}',
//                       style: GoogleFonts.inter(
//                         fontSize: (16 * scaleFactor).sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     if (order.customerName != null) ...[
//                       Gap((4 * scaleFactor).h),
//                       Text(
//                         order.customerName!,
//                         style: GoogleFonts.inter(
//                           fontSize: (12 * scaleFactor).sp,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     buildInfoChip('table no: ${order.tableNumber}', Icons.chair, scaleFactor),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Items Summary
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: (16 * scaleFactor).w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Food Items',
//                   style: GoogleFonts.inter(
//                     fontSize: (14 * scaleFactor).sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 Gap((8 * scaleFactor).h),
//
//                 // Use Obx to watch for expansion changes
//                 Obx(() {
//                   final isExpanded = controller.expandedOrders.contains(order.orderId);
//                   final itemsToShow = isExpanded
//                       ? order.items
//                       : order.items.take(2).toList();
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Show items
//                       ...itemsToShow.map((item) => buildItemSummaryFromModel(item, scaleFactor)),
//
//                       // Show expand/collapse button if more than 2 items
//                       if (order.items.length > 2) ...[
//                         Gap((4 * scaleFactor).h),
//                         GestureDetector(
//                           onTap: () => controller.toggleOrderExpansion(order.orderId),
//                           child: Container(
//                             padding: EdgeInsets.symmetric(vertical: (4 * scaleFactor).h),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   isExpanded
//                                       ? 'Show less'
//                                       : '+${order.items.length - 2} more items',
//                                   style: GoogleFonts.inter(
//                                     fontSize: (12 * scaleFactor).sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.blue[500],
//                                   ),
//                                 ),
//                                 Gap((4 * scaleFactor).w),
//                                 Icon(
//                                   isExpanded
//                                       ? PhosphorIcons.caretUp(PhosphorIconsStyle.regular)
//                                       : PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
//                                   size: (12 * scaleFactor).sp,
//                                   color: Colors.blue[500],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   );
//                 }),
//               ],
//             ),
//           ),
//           Gap((16 * scaleFactor).h),
//           // Order Summary and Actions
//           Container(
//             padding: EdgeInsets.all((8 * scaleFactor).w),
//             decoration: BoxDecoration(
//               color: Colors.green[50],
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular((12 * scaleFactor).r),
//                 bottomRight: Radius.circular((12 * scaleFactor).r),
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Total Summary
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Total Items: ${order.totalItemsCount}',
//                       style: GoogleFonts.inter(
//                         fontSize: (14 * scaleFactor).sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     Text(
//                       controller.formatCurrency(order.totalAmount),
//                       style: GoogleFonts.inter(
//                         fontSize: (16 * scaleFactor).sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.green[600],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Gap((10 * scaleFactor).h),
//                 // Action Buttons
//                 Row(
//                   children: [
//                     // Reject Button
//                     Expanded(
//                       child: Obx(
//                             () => ElevatedButton(
//                           onPressed: controller.isLoading.value
//                               ? null
//                               : () => controller.showRejectDialog(order.orderId),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: Colors.grey[700],
//                             elevation: 0,
//                             side: BorderSide(color: Colors.grey[300]!),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular((8 * scaleFactor).r),
//                             ),
//                             padding: EdgeInsets.symmetric(vertical: (12 * scaleFactor).h),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 PhosphorIcons.x(PhosphorIconsStyle.regular),
//                                 size: (16 * scaleFactor).sp,
//                               ),
//                               Gap((6 * scaleFactor).w),
//                               Text(
//                                 'Reject',
//                                 style: GoogleFonts.inter(
//                                   fontSize: (13 * scaleFactor).sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Gap((12 * scaleFactor).w),
//                     // Accept Button
//                     Expanded(
//                       child: Obx(
//                             () => ElevatedButton(
//                           onPressed: controller.isLoading.value
//                               ? null
//                               : () => controller.acceptOrder(context, order.orderId),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[500],
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular((8 * scaleFactor).r),
//                             ),
//                             padding: EdgeInsets.symmetric(vertical: (12 * scaleFactor).h),
//                           ),
//                           child: controller.isLoading.value
//                               ? SizedBox(
//                             height: (18 * scaleFactor).h,
//                             width: (18 * scaleFactor).w,
//                             child: const CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                               : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 PhosphorIcons.check(PhosphorIconsStyle.regular),
//                                 size: (16 * scaleFactor).sp,
//                               ),
//                               Gap((6 * scaleFactor).w),
//                               Text(
//                                 'Accept',
//                                 style: GoogleFonts.inter(
//                                   fontSize: (13 * scaleFactor).sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to display item from model
//   Widget buildItemSummaryFromModel(PendingOrderItem item, double scaleFactor) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: (6 * scaleFactor).h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: (6 * scaleFactor).w,
//             height: (6 * scaleFactor).w,
//             margin: EdgeInsets.only(top: (9 * scaleFactor).h, right: (8 * scaleFactor).w),
//             decoration: BoxDecoration(
//               color: Colors.black54,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         item.itemName,
//                         style: GoogleFonts.inter(
//                           fontSize: (13 * scaleFactor).sp,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: (8 * scaleFactor).w,
//                         vertical: (4 * scaleFactor).h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular((4 * scaleFactor).r),
//                       ),
//                       child: Text(
//                         'x${item.quantity}',
//                         style: GoogleFonts.inter(
//                           fontSize: (12 * scaleFactor).sp,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty) ...[
//                   Gap((4 * scaleFactor).h),
//                   Text(
//                     'Note: ${item.specialInstructions}',
//                     style: GoogleFonts.inter(
//                       fontSize: (11 * scaleFactor).sp,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.orange[700],
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotelbilling/app/modules/view/ChefPanel/widgets/accept_order_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../controllers/ChefController/accept_order_controller.dart';
import 'component/pending_order_card.dart';

class AcceptOrder extends StatelessWidget {
  const AcceptOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = 0.8;
    final controller = Get.put(AcceptOrderController());
    controller.refreshOrders();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              Expanded(
                child: buildOrdersList(controller, scaleFactor),
              ),
            ],
          ),
          // Rejection Dialog Overlay
          Obx(() => controller.isRejectDialogVisible.value
              ? buildRejectDialog(context, controller, scaleFactor)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget buildOrdersList(AcceptOrderController controller, double scaleFactor) {
    return Obx(() {
      // Show loading indicator
      if (controller.isLoading.value && controller.ordersData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.blue[500],
                strokeWidth: 3,
              ),
              Gap((16 * scaleFactor).h),
              Text(
                'Loading orders...',
                style: GoogleFonts.inter(
                  fontSize: (14 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      // Show error message if exists
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
                size: (64 * scaleFactor).sp,
                color: Colors.red[400],
              ),
              Gap((16 * scaleFactor).h),
              Text(
                'Failed to load orders',
                style: GoogleFonts.inter(
                  fontSize: (16 * scaleFactor).sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Gap((8 * scaleFactor).h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (40 * scaleFactor).w),
                child: Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: (13 * scaleFactor).sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Gap((24 * scaleFactor).h),
              ElevatedButton.icon(
                onPressed: () => controller.refreshOrders(),
                icon: Icon(
                  PhosphorIcons.arrowClockwise(PhosphorIconsStyle.regular),
                  size: (18 * scaleFactor).sp,
                ),
                label: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: (14 * scaleFactor).sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: (24 * scaleFactor).w,
                    vertical: (12 * scaleFactor).h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Show empty state
      if (controller.ordersData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.clipboard(PhosphorIconsStyle.regular),
                size: (64 * scaleFactor).sp,
                color: Colors.grey[400],
              ),
              Gap((16 * scaleFactor).h),
              Text(
                'No pending orders',
                style: GoogleFonts.inter(
                  fontSize: (16 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Gap((8 * scaleFactor).h),
              Text(
                'New orders will appear here',
                style: GoogleFonts.inter(
                  fontSize: (13 * scaleFactor).sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[500],
                ),
              ),
              Gap((24 * scaleFactor).h),
              ElevatedButton.icon(
                onPressed: () => controller.refreshOrders(),
                icon: Icon(
                  PhosphorIcons.arrowClockwise(PhosphorIconsStyle.regular),
                  size: (18 * scaleFactor).sp,
                ),
                label: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: (14 * scaleFactor).sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: (24 * scaleFactor).w,
                    vertical: (12 * scaleFactor).h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Show orders list with pull to refresh
      return RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        color: Colors.blue[500],
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: (20 * scaleFactor).w,
            vertical: (16 * scaleFactor).h,
          ),
          itemCount: controller.ordersData.length,
          itemBuilder: (context, index) {
            final order = controller.ordersData[index];
            return PendingOrderCard(
              order: order,
              controller: controller,
              scaleFactor: scaleFactor,
            );
          },
        ),
      );
    });
  }
}