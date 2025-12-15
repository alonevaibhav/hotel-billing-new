

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
    // final controller = Get.put(AcceptOrderController(),permanent: true);
    final controller = Get.find<AcceptOrderController>();

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