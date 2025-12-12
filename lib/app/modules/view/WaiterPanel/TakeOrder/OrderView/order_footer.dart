import 'package:flutter/material.dart';
import '../../../../../data/models/ResponseModel/table_model.dart';
import '../../../../controllers/WaiterPanelController/select_item_controller.dart';
import '../widgets/select _item_widgets.dart';
import 'order_view_main.dart';


// 3. FOOTER - Bottom action buttons (stays fixed)
class OrderFooter extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;

  const OrderFooter({
    required this.controller,
    required this.tableId,
    required this.tableInfo,
  });

  @override
  Widget build(BuildContext context) {
    return buildBottomSection(
      controller,
      tableId,
      OrderManagementView.scaleFactor,
      context,
      controller.tableInfoToMap(tableInfo),
    );
  }
}
