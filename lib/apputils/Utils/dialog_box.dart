import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmButtonText = 'Delete',
    this.cancelButtonText = 'Cancel',
  }) : super(key: key);

  static const _gradientStart = Color(0xE8FFC107); // Solar yellow
  static const _gradientEnd = Color(0xE0FFA000);   // Deep orange

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOutBack,
          ),
          child: Dialog(
            elevation: 12,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r * 0.8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient header with icon + title
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: (20.h * 0.8), horizontal: (24.w * 0.8)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_gradientStart, _gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r * 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: _gradientEnd.withOpacity(0.4),
                        blurRadius: (8.r * 0.8),
                        offset: Offset(0, (4.h * 0.8)),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: (10.r * 0.8),
                              spreadRadius: (1.r * 0.8),
                            ),
                          ],
                        ),
                        child: Icon(Icons.solar_power, size: (30.sp * 0.8), color: Colors.white),
                      ),
                      SizedBox(width: (12.w * 0.8)),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (22.sp * 0.8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content with slight background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade50, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: (24.w * 0.8), vertical: (20.h * 0.8)),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: (17.sp * 0.8),
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Divider(height: (1.h * 0.8)),

                // Action buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (16.w * 0.8), vertical: (14.h * 0.8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _gradientEnd, width: (1.4.w * 0.8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r * 0.8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: (14.h * 0.8)),
                          ),
                          child: Text(
                            cancelButtonText,
                            style: TextStyle(
                              fontSize: (16.sp * 0.8),
                              color: _gradientEnd,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: (14.w * 0.8)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: _gradientEnd,
                            padding: EdgeInsets.symmetric(vertical: (14.h * 0.8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r * 0.8),
                            ),
                          ),
                          child: Text(
                            confirmButtonText,
                            style: TextStyle(
                              fontSize: (16.sp * 0.8),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
