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
      border: Border.all(color: Colors.black),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: (12 * scaleFactor).sp,
          color: Colors.black,
        ),
        Gap((4 * scaleFactor).w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: (11 * scaleFactor).sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}
