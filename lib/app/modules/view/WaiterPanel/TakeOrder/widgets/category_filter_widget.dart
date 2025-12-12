import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../controllers/WaiterPanelController/add_item_controller.dart';

class CategoryFilterWidget extends StatelessWidget {
  final AddItemsController controller;

  const CategoryFilterWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [

          // Category Filters - Dynamic based on actual categories
          Expanded(
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Quick filter buttons
                  // _buildFilterChip('Featured'),
                  // Gap(8.w),
                  // _buildFilterChip('Vegetarian'),
                  // Gap(8.w),

                  // Divider
                  Container(
                    width: 1,
                    height: 24.h,
                    color: Colors.grey[300],
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                  ),

                  // Dynamic category chips
                  ...controller.categories.map((category) => [
                    _buildCategoryChip(category),
                    if (controller.categories.last != category) Gap(8.w),
                  ]).expand((element) => element).toList(),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Obx(() {
      final isActive = controller.activeFilters.contains(label);

      return GestureDetector(
        onTap: () => controller.toggleFilter(label),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2196F3) : Colors.transparent,
            border: Border.all(
              color: isActive ? const Color(0xFF2196F3) : Colors.grey[400]!,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == 'Featured') ...[
                Icon(
                  Icons.star,
                  size: 14.sp,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
                Gap(4.w),
              ],
              if (label == 'Vegetarian') ...[
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.green,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 6.sp,
                    color: isActive ? Colors.green : Colors.white,
                  ),
                ),
                Gap(4.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryChip(String category) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      final isAll = category == 'All';

      return GestureDetector(
        onTap: () => controller.selectCategory(category),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? (isAll ? const Color(0xFF2196F3) : const Color(0xFF4CAF50))
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected && isAll
                ? Border.all(color: const Color(0xFF2196F3), width: 2)
                : null,
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      );
    });
  }
}