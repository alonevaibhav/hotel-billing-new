
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


/// Reusable loading state widget with customization options
class AppLoadingState extends StatelessWidget {
  final String? message;
  final Color? indicatorColor;
  final double? size;

  const AppLoadingState({
    Key? key,
    this.message,
    this.indicatorColor,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultSize = size ?? 40.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: defaultSize,
            height: defaultSize,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                indicatorColor ?? Theme.of(context).primaryColor,
              ),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            Gap(16.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable empty state widget with customization options
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? iconColor;

  const AppEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[400])!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: iconColor ?? Colors.grey[400],
              ),
            ),
            Gap(16.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              Gap(8.h),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              Gap(24.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable error state widget with customization options
class AppErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;

  const AppErrorState({
    Key? key,
    this.title = 'Something went wrong',
    this.subtitle,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.red[400])!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: iconColor ?? Colors.red[400],
              ),
            ),
            Gap(16.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              Gap(8.h),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              Gap(24.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Extension for easy state switching
extension StateWidgetBuilder on Widget {
  Widget withLoading(bool isLoading, {String? message}) {
    return isLoading
        ? AppLoadingState(message: message)
        : this;
  }
}