import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../../route/app_routes.dart';
import '../../../../../state/app-state.dart';
import '../../../../controllers/WaiterPanelController/add_item_controller.dart';
import '../../sidebar/waiter_drawer.dart';
import '../../../../widgets/header.dart';
import '../widgets/category_filter_widget.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/search_widget.dart';


class AddItemsView extends StatelessWidget {
  final Map<String, dynamic>? table;

  const AddItemsView({super.key, this.table});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddItemsController());
    controller.setTableContext(table);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const WaiterDrawerWidget(),
      resizeToAvoidBottomInset: false,

      // ✔ SINGLE RefreshIndicator
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshCategories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              CommonHeaderWidget(
                customTitle: 'Add Items',
                onBackPressed: () => NavigationService.goBack(),
                showDrawerButton: true,
              ),

              // Search Section
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SearchWidget(controller: controller),
              ),

              // Category Filter
              SizedBox(
                height: 60.h,
                child: CategoryFilterWidget(controller: controller),
              ),

              // ✔ Grid section wrapped in sized box for scroll
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: _buildItemsGrid(controller),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomSection(controller, context),
    );
  }
  // Separate widget for the grid to properly scope the Obx
  Widget _buildItemsGrid(AddItemsController controller) {
    return Obx(() {

      if (controller.isLoading.value) {
        return const AppLoadingState(
          message: 'Loading existing order...',
        );
      }


      // Get the filtered items list
      final items = controller.filteredItems;
      if (items.isEmpty) {
        return const AppEmptyState(
          icon: Icons.restaurant_menu,
          title: 'No items added yet',
          subtitle: 'Tap "add items" to start building your order',
        );
      }




      // Build the grid
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MenuItemCard(
            item: item,
            controller: controller,
          );
        },
      );
    });
  }



  Widget _buildBottomSection(
      AddItemsController controller, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Obx(() => OutlinedButton(
                    onPressed: controller.totalSelectedItems > 0
                        ? () => controller.clearAllSelections()
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
            ),
            Gap(12.w),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.totalSelectedItems > 0
                        ? () => controller.addSelectedItemsToTable(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.totalSelectedItems > 0) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${controller.totalSelectedItems}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Gap(8.w),
                        ],
                        Text(
                          controller.totalSelectedItems > 0
                              ? 'Add to Order'
                              : 'Select Items',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (controller.totalSelectedItems > 0) ...[
                          Gap(8.w),
                          Text(
                            '₹${controller.totalSelectedPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import '../../../../../route/app_routes.dart';
// import '../../../../../state/app_initial_state.dart';
// import '../../../../controllers/WaiterPanelController/add_item_controller.dart';
// import '../../../../widgets/waiter_drawer.dart';
// import '../../../../widgets/header.dart';
// import '../widgets/category_filter_widget.dart';
// import '../widgets/menu_item_card.dart';
// import '../widgets/search_widget.dart';
//
// class AddItemsView extends StatelessWidget {
//   final Map<String, dynamic>? table;
//
//   const AddItemsView({super.key, this.table});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AddItemsController());
//     controller.setTableContext(table);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: const CommonDrawerWidget(),
//       resizeToAvoidBottomInset: false,
//       body: Column(
//         children: [
//           // Header - always visible
//           CommonHeaderWidget(
//             customTitle: 'Add Items',
//             onBackPressed: () => NavigationService.goBack(),
//             showDrawerButton: true,
//           ),
//
//           // Main content with AsyncStateBuilder
//           Expanded(
//             child: AsyncStateBuilder<AddItemsController>(
//               controller: controller,
//               isLoading: controller.isLoading,
//               errorMessage: controller.errorMessage, // Assumes you have this in controller
//               onRefresh: () async {
//                 await controller.refreshCategories();
//               },
//               onRetry: () {
//                 controller.refreshCategories();
//               },
//               isEmpty: (controller) => controller.filteredItems.isEmpty,
//               loadingText: 'Loading items...',
//               emptyStateText: 'No items found',
//               builder: (controller) {
//                 return Column(
//                   children: [
//                     // Search Section
//                     Padding(
//                       padding: EdgeInsets.all(16.w),
//                       child: SearchWidget(controller: controller),
//                     ),
//
//                     // Category Filter
//                     SizedBox(
//                       height: 60.h,
//                       child: CategoryFilterWidget(controller: controller),
//                     ),
//
//                     // Items Grid
//                     Expanded(
//                       child: _buildItemsGrid(controller),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//
//           // Bottom navigation bar - always visible
//           _buildBottomSection(controller, context),
//         ],
//       ),
//     );
//   }
//
//   // Separate widget for the grid
//   Widget _buildItemsGrid(AddItemsController controller) {
//     return Obx(() {
//       final items = controller.filteredItems;
//
//       return GridView.builder(
//         padding: EdgeInsets.all(16.w),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           childAspectRatio: 0.85,
//           crossAxisSpacing: 12.w,
//           mainAxisSpacing: 12.h,
//         ),
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           final item = items[index];
//           return MenuItemCard(
//             item: item,
//             controller: controller,
//           );
//         },
//       );
//     });
//   }
//
//   Widget _buildBottomSection(
//       AddItemsController controller, BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: Obx(() => OutlinedButton(
//                 onPressed: controller.totalSelectedItems > 0
//                     ? () => controller.clearAllSelections()
//                     : null,
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.grey[700],
//                   side: BorderSide(color: Colors.grey[400]!),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                 ),
//                 child: Text(
//                   'Clear All',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               )),
//             ),
//             Gap(12.w),
//             Expanded(
//               flex: 2,
//               child: Obx(() => ElevatedButton(
//                 onPressed: controller.totalSelectedItems > 0
//                     ? () => controller.addSelectedItemsToTable(context)
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2196F3),
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey[300],
//                   disabledForegroundColor: Colors.grey[600],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (controller.totalSelectedItems > 0) ...[
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 8.w,
//                           vertical: 2.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Text(
//                           '${controller.totalSelectedItems}',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Gap(8.w),
//                     ],
//                     Text(
//                       controller.totalSelectedItems > 0
//                           ? 'Add to Order'
//                           : 'Select Items',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     if (controller.totalSelectedItems > 0) ...[
//                       Gap(8.w),
//                       Text(
//                         '₹${controller.totalSelectedPrice.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
