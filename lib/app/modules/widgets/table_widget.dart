// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
//
// class TableCardWidget extends StatelessWidget {
//   final int id;
//   final int tableNumber;
//   final int price;
//   final int time;
//   final bool isOccupied;
//   final VoidCallback onTap;
//
//   const TableCardWidget({
//     super.key,
//     required this.id,
//     required this.tableNumber,
//     required this.price,
//     required this.time,
//     required this.isOccupied,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine card color based on occupancy status
//     Color cardColor;
//     Color borderColor;
//
//     if (isOccupied) {
//       if (price > 0) {
//         cardColor = const Color(0xFFFFCDD2); // Light red for occupied with order
//         borderColor = const Color(0xFFE57373);
//       } else {
//         cardColor = const Color(0xFFFFE0B2); // Light orange for occupied without order
//         borderColor = const Color(0xFFFFB74D);
//       }
//     } else {
//       cardColor = const Color(0xFFC8E6C9); // Light green for available
//       borderColor = const Color(0xFF81C784);
//     }
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(8.r),
//           border: Border.all(
//             color: borderColor,
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         padding: EdgeInsets.all(12.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Header: Table number and status indicator
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '#$tableNumber',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Container(
//                   width: 8.w,
//                   height: 8.w,
//                   decoration: BoxDecoration(
//                     color: isOccupied ? Colors.red : Colors.green,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ],
//             ),
//
//             Gap(8.h),
//
//             // Price section
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Amount',
//                   style: TextStyle(
//                     fontSize: 8.sp,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 Gap(2.h),
//                 Text(
//                   price > 0 ? '₹ $price' : '₹ 0',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//
//             Gap(4.h),
//
//             // Time section
//             Row(
//               children: [
//                 Icon(
//                   Icons.access_time,
//                   size: 10.sp,
//                   color: Colors.black54,
//                 ),
//                 Gap(4.w),
//                 Text(
//                   time > 0 ? '${time}m' : '-',
//                   style: TextStyle(
//                     fontSize: 9.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TableCardWidget extends StatelessWidget {
  final int id;
  final int tableNumber;
  final int price;
  final int time;
  final bool isOccupied;
  final VoidCallback onTap;

  const TableCardWidget({
    super.key,
    required this.id,
    required this.tableNumber,
    required this.price,
    required this.time,
    required this.isOccupied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card styling based on occupancy status
    Color cardColor;
    Color accentColor;
    String statusText;
    IconData statusIcon;
    IconData tableIcon; // Different icon for table status

    if (isOccupied) {
      if (price > 0) {
        cardColor = const Color(0xFFFFF5F5);
        accentColor = const Color(0xFFEF4444);
        statusText = 'Occupied';
        statusIcon = Icons.restaurant_menu;
        tableIcon = Icons.dinner_dining; // Occupied with food
      }
      else {
        cardColor = const Color(0xFFFFF7ED);
        accentColor = const Color(0xFFF59E0B);
        statusText = 'Reserved';
        statusIcon = Icons.event_seat;
        tableIcon = Icons.event_available; // Reserved
      }
    } else {
      cardColor = const Color(0xFFF0FDF4);
      accentColor = const Color(0xFF10B981);
      statusText = 'Available';
      statusIcon = Icons.check_circle_outline;
      tableIcon = Icons.table_bar; // Available/empty table
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: accentColor.withOpacity(0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header: Table number and status indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  tableIcon, // Dynamic icon based on status
                  size: 21.sp,
                  color: accentColor,
                ),
                Gap(4.w),
                Text(
                  'Table $tableNumber',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            Gap(8.h),

            // Price section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                Gap(2.h),
                Text(
                  price > 0 ? '₹ $price' : '₹ 0',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            Gap(4.h),

            // Time section
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 10.sp,
                  color: Colors.black54,
                ),
                Gap(4.w),
                Text(
                  time > 0 ? '${time}m' : '-',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}