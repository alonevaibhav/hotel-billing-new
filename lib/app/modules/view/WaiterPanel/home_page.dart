import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../../../apputils/Utils/double_tap_to_exit.dart';
import '../../controllers/WaiterPanelController/home_controller.dart';
import 'sidebar/waiter_drawer.dart';
import '../../widgets/header.dart';
import 'ReadyOrder/ready_order.dart';
import 'TakeOrder/take_order_main.dart';

class WaiterDashboardView extends StatelessWidget {
  const WaiterDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantController controller = Get.put(RestaurantController());

    return DoubleBackToExit(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: const WaiterDrawerWidget(), // Use the centralized drawer
          body: Column(
            children: [
              // Common Header
              const CommonHeaderWidget(
                showBackButton: false,
                showDrawerButton: true,
              ),
              // Main Content Area
              Expanded(
                child: Obx(() {
                  // Show content based on selection
                  if (controller.selectedMainButton.value == 'take_orders') {
                    return _buildTakeOrderContent(controller);
                  } else {
                    return _buildReadyOrderContent(controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Take Order Content
  Widget _buildTakeOrderContent(RestaurantController controller) {
    return Column(
      children: [
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Take Orders Button (Active)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B73DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'take orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              // Ready Orders Button (Inactive)
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.handleReadyOrders(), // Fixed: Added onTap
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'ready orders',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // TakeOrder content without Scaffold
        Expanded(
          child: TakeOrderContent(), // Make sure this widget exists
        ),
      ],
    );
  }

  // Ready Order Content - Fixed structure
  Widget _buildReadyOrderContent(RestaurantController controller) {
    return Column(
      children: [
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Take Orders Button (Inactive)
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.handleTakeOrders(), // Fixed: Added onTap
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'take orders',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              // Ready Orders Button (Active)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B73DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'ready orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Ready orders content - Fixed: Removed incorrect nesting
        Expanded(
          child:
          ReadyOrder(), // Make sure this widget exists and doesn't contain Scaffold
        ),
      ],
    );
  }
}
