import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../apputils/Utils/common_utils.dart';
import '../../../controllers/ChefController/accept_order_controller.dart';

Widget buildInfoChip(String text, IconData icon, double scaleFactor) {
  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: (8 * scaleFactor).w, vertical: (4 * scaleFactor).h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular((6 * scaleFactor).r),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: (12 * scaleFactor).sp,
          color: Colors.grey[600],
        ),
        Gap((4 * scaleFactor).w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: (11 * scaleFactor).sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}

Widget buildItemSummary(Map<String, dynamic> item, double scaleFactor) {
  final quantity = item['quantity'] ?? 0;
  final name = item['name'] ?? '';
  final isVegetarian = (item['is_vegetarian'] ?? 0) == 1;
  return Padding(
    padding: EdgeInsets.only(bottom: (6 * scaleFactor).h),
    child: Row(
      children: [
        // Vegetarian/Non-vegetarian indicator
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
        // Item name
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: (13 * scaleFactor).sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Quantity badge
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: (6 * scaleFactor).w, vertical: (2 * scaleFactor).h),
          decoration: BoxDecoration(
            color: Colors.blue[500],
            borderRadius: BorderRadius.circular((3 * scaleFactor).r),
          ),
          child: Text(
            '$quantity',
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

Widget buildRejectDialog(BuildContext context, AcceptOrderController controller,
    double scaleFactor) {
  return Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: Container(
        margin: EdgeInsets.all((24 * scaleFactor).w),
        padding: EdgeInsets.all((20 * scaleFactor).w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular((16 * scaleFactor).r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reason For Cancelling The Order',
                  style: GoogleFonts.inter(
                    fontSize: (16 * scaleFactor).sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.hideRejectDialog(),
                  child: Container(
                    padding: EdgeInsets.all((4 * scaleFactor).w),
                    child: Icon(
                      PhosphorIcons.x(PhosphorIconsStyle.regular),
                      size: (20 * scaleFactor).sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            Gap(1.h),
            // Reason Text Field
            CommonUiUtils.buildTextFormField(
              controller: controller.reasonController,
              label: '',
              hint: 'explain your reason',
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              validator: controller.validateRejectionReason,
              onChanged: controller.updateRejectionReason,
              icon: Icons.import_contacts,
            ),
            Gap((20 * scaleFactor).h),
            // Cancel Order Button
            SizedBox(
              width: double.infinity,
              child: Obx(
                    () {
                  // ✅ Check if the current item is being processed
                  final isProcessing = controller.selectedItemId.value != null &&
                      controller.processingItems.contains(controller.selectedItemId.value);

                  return ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => controller.rejectItem(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isProcessing ? Colors.grey[400] : Colors.blue[500],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                      ),
                      padding:
                      EdgeInsets.symmetric(vertical: (14 * scaleFactor).h),
                    ),
                    child: isProcessing
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: (18 * scaleFactor).sp,
                          width: (18 * scaleFactor).sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        Gap((12 * scaleFactor).w),
                        Text(
                          'Cancelling...',
                          style: GoogleFonts.inter(
                            fontSize: (14 * scaleFactor).sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      'Cancel Order',
                      style: GoogleFonts.inter(
                        fontSize: (14 * scaleFactor).sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}