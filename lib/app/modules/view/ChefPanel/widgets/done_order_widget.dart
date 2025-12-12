import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

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
