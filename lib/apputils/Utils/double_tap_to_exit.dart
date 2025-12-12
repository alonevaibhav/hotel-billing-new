
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/core/constants/color_constant.dart';
import 'common_utils.dart';

class DoubleBackToExit extends StatefulWidget {
  final Widget child;

  const DoubleBackToExit({Key? key, required this.child}) : super(key: key);

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;

          Fluttertoast.showToast(
            msg: 'Press back again to exit',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          return false;
        }
        return true;
      },
      child: widget.child,
    );
  }
}



class PopToExitGetX extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? message;

  const PopToExitGetX({
    Key? key,
    required this.child,
    this.title,
    this.message,
  }) : super(key: key);

  @override
  State<PopToExitGetX> createState() => _PopToExitGetXState();
}

class _PopToExitGetXState extends State<PopToExitGetX> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog();
      },
      child: widget.child,
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await CommonUiUtils.showCustomDialog(
      context: Get.context!,
      title: widget.title ?? 'Exit Form',
      message: widget.message ??
          'Are you sure you want to exit this form? All unsaved progress will be lost.',
      primaryButtonText: 'Exit',
      secondaryButtonText: 'Cancel',
      icon: PhosphorIcons.warning(PhosphorIconsStyle.regular),
      iconColor: AppColors.primaryLight,
      onPrimaryPressed: () {
        Navigator.of(Get.context!).pop(true);
      },
      onSecondaryPressed: () {
        Navigator.of(Get.context!).pop(false);
      },
      barrierDismissible: false,
    );

    return result ?? false;
  }
}

// Utility class for handling exit confirmations
class ExitConfirmationUtils {
  /// Shows exit confirmation dialog and returns true if user wants to exit
  static Future<bool> showExitDialog({
    String? title,
    String? message,
  }) async {
    final result = await CommonUiUtils.showCustomDialog(
      context: Get.context!,
      title: title ?? 'Exit Form',
      message: message ??
          'Are you sure you want to exit this form? All unsaved progress will be lost.',
      primaryButtonText: 'Exit',
      secondaryButtonText: 'Cancel',
      icon: PhosphorIcons.warning(PhosphorIconsStyle.regular),
      iconColor: AppColors.primaryLight,
      onPrimaryPressed: () {
        Navigator.of(Get.context!).pop(true);
      },
      onSecondaryPressed: () {
        Navigator.of(Get.context!).pop(false);
      },
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Handles back button press with confirmation
  static Future<void> handleBackPress() async {
    final shouldExit = await showExitDialog();
    if (shouldExit) {
      Get.back();
    }
  }

  /// Creates a back button with exit confirmation
  static Widget buildBackButton({
    Color iconColor = Colors.white,
    String? title,
    String? message,
  }) {
    return IconButton(
      icon: Icon(
        PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
        color: iconColor,
      ),
      onPressed: () async {
        final shouldExit = await showExitDialog(
          title: title,
          message: message,
        );
        if (shouldExit) {
          Get.back();
        }
      },
    );
  }
}