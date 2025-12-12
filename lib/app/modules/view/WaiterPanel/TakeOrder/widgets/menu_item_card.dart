import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../controllers/WaiterPanelController/add_item_controller.dart';

class MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final AddItemsController controller;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Remove the Obx here since the parent already has it
    final quantity = item['quantity'] as int;
    final isSelected = quantity > 0;
    final price = double.parse(item['price'].toString());

    return Container(
      decoration: BoxDecoration(
        color: _getCardColor(item),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Main Content
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name
                Expanded(
                  child: Text(
                    item['item_name'] ?? 'Unknown Item',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(4.h),

                // Price
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Gap(8.h),

                // Quantity Controls - Only this part needs to be reactive
                _buildQuantitySection(quantity, isSelected),
              ],
            ),
          ),

          // Featured/Special indicators
          Positioned(
            top: 4.w,
            right: 4.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // align to the right
              children: [
                if (item['is_featured'] == 1)
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.star(PhosphorIconsStyle.fill),
                      size: 8.sp,
                      color: Colors.white,
                    ),
                  ),
                if (item['is_featured'] == 1 && item['is_vegetarian'] == 1)
                  SizedBox(height: 4.h), // spacing between indicators
                if (item['is_vegetarian'] == 1)
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: Icon(
                      Icons.circle,
                      size: 6.sp,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildQuantitySection(int quantity, bool isSelected) {
    if (isSelected) {
      return _buildQuantityControls(quantity);
    } else {
      return _buildAddButton();
    }
  }

  Color _getCardColor(Map<String, dynamic> item) {
    if ((item['quantity'] as int) > 0) {
      return const Color(0xFF2196F3).withOpacity(0.1);
    }

    // Different colors for different states as shown in screenshots
    if (item['is_featured'] == 1) {
      return const Color(0xFF4CAF50).withOpacity(0.1); // Green for featured
    }

    return Colors.grey[100]!; // Default gray
  }

  Widget _buildQuantityControls(int quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => controller.decrementItemQuantity(item),
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: const Color(0xFF2196F3)),
            ),
            child: Icon(
              Icons.remove,
              size: 14.sp,
              color: const Color(0xFF2196F3),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => controller.incrementItemQuantity(item),
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Icon(
              Icons.add,
              size: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => controller.incrementItemQuantity(item),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          'ADD',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
