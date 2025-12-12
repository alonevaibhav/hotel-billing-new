import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../../controllers/WaiterPanelController/take_order_controller.dart';
import '../../../widgets/table_widget.dart';

class TakeOrderContent extends StatelessWidget {
  const TakeOrderContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TakeOrdersController(), permanent: true);

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshTables();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          // Loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (controller.errorMessage.isNotEmpty) {
            return Center(
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
                    onPressed: controller.refreshTables,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state - observe the length to trigger reactivity
          if (controller.groupedTables.length == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const Gap(16),
                  const Text(
                    'No tables available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display tables grouped by area
          // Access .keys and .length to ensure GetX tracks changes
          final areas = controller.groupedTables.keys.toList();
          final areaCount = areas.length;

          return ListView.builder(
            itemCount: areaCount,
            itemBuilder: (context, areaIndex) {
              final areaName = areas[areaIndex];

              // Wrap in Obx to observe changes to individual area tables
              return Obx(() {
                final tables = controller.groupedTables[areaName] ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4), // Light yellow background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Area title with table count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            areaName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${tables.length} tables',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(16),

                      // Tables grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: tables.length,
                        itemBuilder: (context, index) {
                          final tableInfo = tables[index];
                          final table = tableInfo.table;
                          final order = tableInfo.currentOrder;

                          return TableCardWidget(
                            id: table.id,
                            tableNumber: int.tryParse(table.tableNumber) ?? 0,
                            price: (order?.totalAmount ?? 0).toInt(),
                            time: order != null
                                ? controller.calculateElapsedTime(order.createdAt)
                                : 0,
                            isOccupied: table.status == 'occupied',
                            onTap: () => controller.handleTableTap(tableInfo, context),
                          );
                        },
                      ),
                    ],
                  ),
                );
              });
            },
          );
        }),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gap/gap.dart';
// import '../../../../state/app_initial_state.dart';
// import '../../../controllers/WaiterPanelController/take_order_controller.dart';
// import '../../../widgets/table_widget.dart';
//
// class TakeOrderContent extends StatelessWidget {
//   const TakeOrderContent({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(TakeOrdersController(), permanent: true);
//
//     return AsyncStateBuilder<TakeOrdersController>(
//       controller: controller,
//       isLoading: controller.isLoading,
//       errorMessage: controller.errorMessage,
//       onRefresh: () async {
//         await controller.refreshTables();
//       },
//       onRetry: () {
//         controller.refreshTables();
//       },
//       isEmpty: (controller) => controller.groupedTables.isEmpty,
//       loadingText: 'Loading tables...',
//       emptyStateText: 'No tables available',
//       errorTitle: 'Failed to Load Tables',
//       // Pass reactive variables that change via sockets
//       observeData: [
//         controller.groupedTables,
//         controller.allTables,
//       ],
//
//       builder: (controller) {
//         // Display tables grouped by area
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: ListView.builder(
//             itemCount: controller.groupedTables.length,
//             itemBuilder: (context, areaIndex) {
//               final areaName = controller.groupedTables.keys.elementAt(areaIndex);
//               final tables = controller.groupedTables[areaName] ?? [];
//
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF9C4), // Light yellow background
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Area title with table count
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           areaName,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black12,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             '${tables.length} tables',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const Gap(16),
//
//                     // Tables grid
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 8,
//                         mainAxisSpacing: 8,
//                         childAspectRatio: 0.8,
//                       ),
//                       itemCount: tables.length,
//                       itemBuilder: (context, index) {
//                         final tableInfo = tables[index];
//                         final table = tableInfo.table;
//                         final order = tableInfo.currentOrder;
//
//                         return TableCardWidget(
//                           id: table.id,
//                           tableNumber: int.tryParse(table.tableNumber) ?? 0,
//                           price: (order?.totalAmount ?? 0).toInt(),
//                           time: order != null
//                               ? controller.calculateElapsedTime(order.createdAt)
//                               : 0,
//                           isOccupied: table.status == 'occupied',
//                           onTap: () => controller.handleTableTap(tableInfo, context),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }