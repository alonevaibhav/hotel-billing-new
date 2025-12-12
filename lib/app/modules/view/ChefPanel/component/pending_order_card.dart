// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import '../../../../data/models/ResponseModel/pending_orders_model.dart';
// import '../../../controllers/ChefController/accept_order_controller.dart';
//
// class PendingOrderCard extends StatelessWidget {
//   final GroupedOrder order;
//   final AcceptOrderController controller;
//   final double scaleFactor;
//
//   const PendingOrderCard({
//     super.key,
//     required this.order,
//     required this.controller,
//     required this.scaleFactor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
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
//           _buildOrderHeader(),
//           // Items Summary
//           _buildItemsSection(),
//           Gap((16 * scaleFactor).h),
//           // Order Summary and Actions
//           _buildFooterSection(context),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderHeader() {
//     return Container(
//       padding: EdgeInsets.all((16 * scaleFactor).w),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Order noo. ${order.orderId}',
//                 style: GoogleFonts.inter(
//                   fontSize: (16 * scaleFactor).sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               if (order.customerName != null) ...[
//                 Gap((4 * scaleFactor).h),
//                 Text(
//                   order.customerName!,
//                   style: GoogleFonts.inter(
//                     fontSize: (12 * scaleFactor).sp,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           Row(
//             children: [
//               _buildInfoChip('table no: ${order.tableNumber}', Icons.chair),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoChip(String label, IconData icon) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: (12 * scaleFactor).w,
//         vertical: (6 * scaleFactor).h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular((6 * scaleFactor).r),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: (14 * scaleFactor).sp,
//             color: Colors.blue[700],
//           ),
//           Gap((6 * scaleFactor).w),
//           Text(
//             label,
//             style: GoogleFonts.inter(
//               fontSize: (12 * scaleFactor).sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.blue[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemsSection() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: (16 * scaleFactor).w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Food Items',
//             style: GoogleFonts.inter(
//               fontSize: (14 * scaleFactor).sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//             ),
//           ),
//           Gap((8 * scaleFactor).h),
//           Obx(() {
//             final isExpanded = controller.expandedOrders.contains(order.orderId);
//             final itemsToShow = isExpanded
//                 ? order.items
//                 : order.items.take(2).toList();
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Show items
//                 ...itemsToShow.map((item) => _buildItemSummary(item)),
//
//                 // Show expand/collapse button if more than 2 items
//                 if (order.items.length > 2) ...[
//                   Gap((4 * scaleFactor).h),
//                   GestureDetector(
//                     onTap: () => controller.toggleOrderExpansion(order.orderId),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: (4 * scaleFactor).h),
//                       child: Row(
//                         children: [
//                           Text(
//                             isExpanded
//                                 ? 'Show less'
//                                 : '+${order.items.length - 2} more items',
//                             style: GoogleFonts.inter(
//                               fontSize: (12 * scaleFactor).sp,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.blue[500],
//                             ),
//                           ),
//                           Gap((4 * scaleFactor).w),
//                           Icon(
//                             isExpanded
//                                 ? PhosphorIcons.caretUp(PhosphorIconsStyle.regular)
//                                 : PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
//                             size: (12 * scaleFactor).sp,
//                             color: Colors.blue[500],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemSummary(PendingOrderItem item) {
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
//
//   Widget _buildFooterSection(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all((8 * scaleFactor).w),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular((12 * scaleFactor).r),
//           bottomRight: Radius.circular((12 * scaleFactor).r),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Total Summary
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total Items: ${order.totalItemsCount}',
//                 style: GoogleFonts.inter(
//                   fontSize: (14 * scaleFactor).sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               Text(
//                 controller.formatCurrency(order.totalAmount),
//                 style: GoogleFonts.inter(
//                   fontSize: (16 * scaleFactor).sp,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.green[600],
//                 ),
//               ),
//             ],
//           ),
//           Gap((10 * scaleFactor).h),
//           // Action Buttons
//           _buildActionButtons(context),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(BuildContext context) {
//     return Row(
//       children: [
//         // Reject Button
//         Expanded(
//           child: Obx(
//                 () => ElevatedButton(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () => controller.showRejectDialog(order.orderId),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.grey[700],
//                 elevation: 0,
//                 side: BorderSide(color: Colors.grey[300]!),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular((8 * scaleFactor).r),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: (12 * scaleFactor).h),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     PhosphorIcons.x(PhosphorIconsStyle.regular),
//                     size: (16 * scaleFactor).sp,
//                   ),
//                   Gap((6 * scaleFactor).w),
//                   Text(
//                     'Reject',
//                     style: GoogleFonts.inter(
//                       fontSize: (13 * scaleFactor).sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Gap((12 * scaleFactor).w),
//         // Accept Button
//         Expanded(
//           child: Obx(
//                 () => ElevatedButton(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () => controller.acceptOrder(context, order.orderId),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[500],
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular((8 * scaleFactor).r),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: (12 * scaleFactor).h),
//               ),
//               child: controller.isLoading.value
//                   ? SizedBox(
//                 height: (18 * scaleFactor).h,
//                 width: (18 * scaleFactor).w,
//                 child: const CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     PhosphorIcons.check(PhosphorIconsStyle.regular),
//                     size: (16 * scaleFactor).sp,
//                   ),
//                   Gap((6 * scaleFactor).w),
//                   Text(
//                     'Accept',
//                     style: GoogleFonts.inter(
//                       fontSize: (13 * scaleFactor).sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../data/models/ResponseModel/pending_orders_model.dart';
import '../../../controllers/ChefController/accept_order_controller.dart';

class PendingOrderCard extends StatelessWidget {
  final GroupedOrder order;
  final AcceptOrderController controller;
  final double scaleFactor;

  const PendingOrderCard({
    super.key,
    required this.order,
    required this.controller,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: (16 * scaleFactor).h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((12 * scaleFactor).r),
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
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
          _buildOrderHeader(),
          Divider(height: 1, color: Colors.grey[200]),
          _buildItemsList(),
          _buildFooterSection(context),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular((12 * scaleFactor).r),
          topRight: Radius.circular((12 * scaleFactor).r),
        )
      ),
      padding: EdgeInsets.all((16 * scaleFactor).w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Order #${order.orderId}',
                      style: GoogleFonts.inter(
                        fontSize: (16 * scaleFactor).sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Gap((8 * scaleFactor).w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: (8 * scaleFactor).w,
                        vertical: (4 * scaleFactor).h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular((4 * scaleFactor).r),
                      ),
                      child: Text(
                        '${order.items.length} items',
                        style: GoogleFonts.inter(
                          fontSize: (11 * scaleFactor).sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (order.customerName != null) ...[
                  Gap((4 * scaleFactor).h),
                  Text(
                    order.customerName!,
                    style: GoogleFonts.inter(
                      fontSize: (12 * scaleFactor).sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildInfoChip('Table ${order.tableNumber}', Icons.table_restaurant),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (12 * scaleFactor).w,
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
          Gap((6 * scaleFactor).w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: (12 * scaleFactor).sp,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      final isExpanded = controller.expandedOrders.contains(order.orderId);
      final itemsToShow = isExpanded
          ? order.items
          : order.items.take(3).toList();

      return Column(
        children: [
          ...itemsToShow.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == itemsToShow.length - 1 &&
                (isExpanded || order.items.length <= 3);

            return _buildItemRow(item, isLast);
          }),

          if (order.items.length > 3) ...[
            InkWell(
              onTap: () => controller.toggleOrderExpansion(order.orderId),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: (12 * scaleFactor).h,
                  horizontal: (16 * scaleFactor).w,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded
                          ? 'Show less'
                          : 'Show ${order.items.length - 3} more items',
                      style: GoogleFonts.inter(
                        fontSize: (13 * scaleFactor).sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
                      ),
                    ),
                    Gap((6 * scaleFactor).w),
                    Icon(
                      isExpanded
                          ? PhosphorIcons.caretUp(PhosphorIconsStyle.regular)
                          : PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                      size: (14 * scaleFactor).sp,
                      color: Colors.blue[600],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildItemRow(PendingOrderItem item, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (16 * scaleFactor).w,
          vertical: (12 * scaleFactor).h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: GoogleFonts.inter(
                            fontSize: (14 * scaleFactor).sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Gap((8 * scaleFactor).w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: (8 * scaleFactor).w,
                          vertical: (4 * scaleFactor).h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular((4 * scaleFactor).r),
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: GoogleFonts.inter(
                            fontSize: (12 * scaleFactor).sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap((4 * scaleFactor).h),
                  Text(
                    controller.formatCurrency(item.totalPriceDouble),
                    style: GoogleFonts.inter(
                      fontSize: (13 * scaleFactor).sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                  if (item.specialInstructions != null &&
                      item.specialInstructions!.isNotEmpty) ...[
                    Gap((6 * scaleFactor).h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: (10 * scaleFactor).w,
                        vertical: (6 * scaleFactor).h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular((6 * scaleFactor).r),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.notepad(PhosphorIconsStyle.regular),
                            size: (12 * scaleFactor).sp,
                            color: Colors.orange[700],
                          ),
                          Gap((6 * scaleFactor).w),
                          Flexible(
                            child: Text(
                              item.specialInstructions!,
                              style: GoogleFonts.inter(
                                fontSize: (11 * scaleFactor).sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Gap((12 * scaleFactor).w),
            _buildItemActions(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemActions(PendingOrderItem item) {
    return Obx(() {
      final isProcessing = controller.processingItems.contains(item.id);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reject Button - Icon Only
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isProcessing
                  ? null
                  : () => controller.showRejectDialogForItem(order.orderId, item.id),
              borderRadius: BorderRadius.circular((8 * scaleFactor).r),
              child: Container(
                padding: EdgeInsets.all((8 * scaleFactor).w),
                decoration: BoxDecoration(
                  color: isProcessing ? Colors.grey[100] : Colors.red[50],
                  borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                  border: Border.all(
                    color: isProcessing ? Colors.grey[300]! : Colors.red[200]!,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.x(PhosphorIconsStyle.bold),
                  size: (18 * scaleFactor).sp,
                  color: isProcessing ? Colors.grey[400] : Colors.red[600],
                ),
              ),
            ),
          ),
          Gap((8 * scaleFactor).w),
          // Accept Button - Icon Only
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isProcessing
                  ? null
                  : () => controller.acceptItem(order.orderId, item.id),
              borderRadius: BorderRadius.circular((8 * scaleFactor).r),
              child: Container(
                padding: EdgeInsets.all((8 * scaleFactor).w),
                decoration: BoxDecoration(
                  color: isProcessing ? Colors.grey[300] : Colors.green[600],
                  borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                  boxShadow: isProcessing ? null : [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isProcessing
                    ? SizedBox(
                  height: (18 * scaleFactor).sp,
                  width: (18 * scaleFactor).sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(
                  PhosphorIcons.check(PhosphorIconsStyle.bold),
                  size: (18 * scaleFactor).sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (16 * scaleFactor).w,
        vertical: (12 * scaleFactor).h,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular((12 * scaleFactor).r),
          bottomRight: Radius.circular((12 * scaleFactor).r),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Total',
                style: GoogleFonts.inter(
                  fontSize: (11 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Gap((2 * scaleFactor).h),
              Text(
                controller.formatCurrency(order.totalAmount),
                style: GoogleFonts.inter(
                  fontSize: (18 * scaleFactor).sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Qty',
                style: GoogleFonts.inter(
                  fontSize: (11 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Gap((2 * scaleFactor).h),
              Text(
                '${order.totalItemsCount}',
                style: GoogleFonts.inter(
                  fontSize: (18 * scaleFactor).sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}