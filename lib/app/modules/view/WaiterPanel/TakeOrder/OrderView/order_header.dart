import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../../data/models/ResponseModel/table_model.dart';
import '../../../../controllers/WaiterPanelController/select_item_controller.dart';
import '../../../../model/table_order_state_mode.dart';
import 'order_view_main.dart';

class OrderHeader extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;
  final TableOrderState tableState;

  const OrderHeader({super.key,
    required this.controller,
    required this.tableId,
    required this.tableInfo,
    required this.tableState,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontSize: 16.sp * OrderManagementView.scaleFactor,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        // Urgent Button
        Obx(() {
          final isUrgent = tableState.isMarkAsUrgent.value;
          return OutlinedButton.icon(
            onPressed: () =>
                controller.toggleUrgentForTable(tableId, context, tableInfo),
            style: OutlinedButton.styleFrom(
              backgroundColor:
              isUrgent ? Colors.orange.withOpacity(0.1) : Colors.white,
              side: BorderSide(
                color: isUrgent ? Colors.orange[600]! : Colors.grey[300]!,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.r * OrderManagementView.scaleFactor),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w * OrderManagementView.scaleFactor,
                vertical: 8.h * OrderManagementView.scaleFactor,
              ),
            ),
            icon: Icon(
              isUrgent ? Icons.priority_high : Icons.schedule,
              size: 16.sp * OrderManagementView.scaleFactor,
              color: isUrgent ? Colors.orange[700] : Colors.grey[600],
            ),
            label: Text(
              isUrgent ? 'Urgent' : 'Mark Urgent',
              style: TextStyle(
                fontSize: 12.sp * OrderManagementView.scaleFactor,
                fontWeight: FontWeight.w500,
                color: isUrgent ? Colors.orange[700] : Colors.grey[700],
              ),
            ),
          );
        }),
        Gap(8.w * OrderManagementView.scaleFactor),
        // Add Items Button
        ElevatedButton.icon(
          onPressed: () => controller.navigateToAddItems(tableId, tableInfo),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 1,
            shadowColor: Colors.blue.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w * OrderManagementView.scaleFactor,
              vertical: 8.h * OrderManagementView.scaleFactor,
            ),
          ),
          icon: Icon(Icons.add, size: 18.sp * OrderManagementView.scaleFactor),
          label: Text(
            'Add Items',
            style: TextStyle(
              fontSize: 12.sp * OrderManagementView.scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
