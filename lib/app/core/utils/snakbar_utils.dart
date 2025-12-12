import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
enum SnackBarType {
  success,
  error,
  warning,
  info,
  custom,
}

class SnackBarUtil {
  // NEW show() METHOD
  static void show(
      BuildContext context,
      String message, {
        String? title,
        SnackBarType type = SnackBarType.info,
        Duration duration = const Duration(seconds: 2),
        IconData? icon,
        Color? backgroundColor,
        Color textColor = Colors.white,
      }) {
    switch (type) {
      case SnackBarType.success:
        showSuccess(context, message, title: title, duration: duration);
        break;

      case SnackBarType.error:
        showError(context, message, title: title, duration: duration);
        break;

      case SnackBarType.warning:
        showWarning(context, message, title: title, duration: duration);
        break;

      case SnackBarType.info:
        showInfo(context, message, title: title, duration: duration);
        break;

      case SnackBarType.custom:
        showCustom(
          context: context,
          message: message,
          title: title,
          icon: icon,
          backgroundColor: backgroundColor,
          textColor: textColor,
          duration: duration,
        );
        break;
    }
  }

  // EXISTING METHODS ------------------------------------------

  static void showSuccess(
      BuildContext context,
      String message, {
        String? title,
        Duration? duration,
      }) {
    _showSnackBar(
      context,
      message: message,
      title: title,
      icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
      backgroundColor: Colors.green.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showError(
      BuildContext context,
      String message, {
        String? title,
        Duration? duration,
      }) {
    _showSnackBar(
      context,
      message: message,
      title: title,
      icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
      backgroundColor: Colors.red.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showWarning(
      BuildContext context,
      String message, {
        String? title,
        Duration? duration,
      }) {
    _showSnackBar(
      context,
      message: message,
      title: title,
      icon: PhosphorIcons.warning(PhosphorIconsStyle.fill),
      backgroundColor: Colors.orange.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showInfo(
      BuildContext context,
      String message, {
        String? title,
        Duration? duration,
      }) {
    _showSnackBar(
      context,
      message: message,
      title: title,
      icon: PhosphorIcons.info(PhosphorIconsStyle.fill),
      backgroundColor: Colors.blue.withOpacity(0.9),
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showCustom({
    required BuildContext context,
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      title: title,
      icon: icon,
      backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.9),
      textColor: textColor ?? Colors.white,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void _showSnackBar(
      BuildContext context, {
        required String message,
        String? title,
        IconData? icon,
        required Color backgroundColor,
        Color textColor = Colors.white,
        required Duration duration,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: textColor, size: 20.sp),
            if (icon != null) SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  Text(
                    message,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
