import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/core/constants/color_constant.dart';
import 'get_text_form.dart';
import 'get_translation_controller.dart';

class TranslatedUIUtils {
  static const double sizeFactor = 0.75; // Size constant variable

  /// Translatable Text Widget with proper cache handling
  static Widget buildTranslatableText({
    required String text,
    required TextStyle style,
    String sourceLanguage = 'en',
    String? targetLanguage,
    bool enableTranslation = true,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Widget? loadingWidget,
  }) {
    // Check if TranslationController is registered before using it
    if (!Get.isRegistered<TranslationController>()) {
      return Text(text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow);
    }

    return GetBuilder<TranslationController>(
      builder: (controller) {
        // Use a unique key that includes the language to force rebuilds when language changes
        final currentLang = controller.currentLanguage?.code ?? 'en';
        final key = Key('${text}_${sourceLanguage}_${currentLang}');

        return GetTranslatableText(
          text,
          key: key,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          enableTranslation: enableTranslation,
          loadingWidget: loadingWidget ??
              SizedBox(
                height: style.fontSize ?? 16,
                width: 20.w * sizeFactor,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: style.color ?? AppColors.primaryLight,
                ),
              ),
          useQueuedTranslation: true,
          enableCache: true,
          debounceDelay: const Duration(milliseconds: 150),
        );
      },
    );
  }

  static Widget buildStepHeader(String title, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTranslatableText(
          text: title,
          style: GoogleFonts.poppins(
            fontSize: 22.sp * sizeFactor,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryLight,
          ),
          sourceLanguage: 'en',
        ),
        if (subtitle != null && subtitle.trim().isNotEmpty) ...[
          Gap(6.h * sizeFactor),
          buildTranslatableText(
            text: subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14.sp * sizeFactor,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            sourceLanguage: 'en',
          ),
        ],
      ],
    );
  }

  static Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    String sourceLanguage = 'en',
    String? errorText, // Add errorText parameter
    ValueChanged<String>? onChanged, // Add onChanged parameter
    GestureTapCallback? onTap, // Add onTap parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTranslatableText(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp * sizeFactor,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          sourceLanguage: sourceLanguage,
        ),
        Gap(8.h * sizeFactor),
        GetBuilder<TranslationController>(
          builder: (translationController) {
            // Translate hint text reactively
            return FutureBuilder<String>(
              future: _getTranslatedText(hint, sourceLanguage),
              builder: (context, snapshot) {
                final translatedHint = snapshot.data ?? hint;

                return TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  style: GoogleFonts.poppins(fontSize: 16.sp * sizeFactor),
                  validator: validator,
                  onChanged: onChanged, // Pass onChanged to TextFormField
                  onTap: onTap, // Pass onTap to TextFormField
                  decoration: InputDecoration(
                    hintText: translatedHint,
                    prefixIcon: Icon(icon,
                        color: AppColors.primaryLight,
                        size: 20.w * sizeFactor),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide: BorderSide(
                          color: AppColors.lightColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide: BorderSide(
                          color: AppColors.lightColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide:
                      BorderSide(color: AppColors.primaryLight, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide: BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide: BorderSide(color: AppColors.error, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w * sizeFactor,
                        vertical: 16.h * sizeFactor),
                    errorText: errorText, // Pass errorText to InputDecoration
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  static Widget buildQuestionCard({
    required String question,
    required bool? selectedValue,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w * TranslatedUIUtils.sizeFactor),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r * TranslatedUIUtils.sizeFactor),
        border: Border.all(color: AppColors.lightColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedUIUtils.buildTranslatableText(
            text: question,
            style: GoogleFonts.poppins(
              fontSize: 16.sp * TranslatedUIUtils.sizeFactor,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Gap(16.h * TranslatedUIUtils.sizeFactor),
          Row(
            children: [
              Expanded(
                child: buildOptionButton(
                  text: 'Yes',
                  isSelected: selectedValue == true,
                  onTap: () => onChanged(true),
                  icon: PhosphorIcons.check(PhosphorIconsStyle.regular),
                ),
              ),
              Gap(12.w * TranslatedUIUtils.sizeFactor),
              Expanded(
                child: buildOptionButton(
                  text: 'No',
                  isSelected: selectedValue == false,
                  onTap: () => onChanged(false),
                  icon: PhosphorIcons.x(PhosphorIconsStyle.regular),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildOptionButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r * TranslatedUIUtils.sizeFactor),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h * TranslatedUIUtils.sizeFactor,
          horizontal: 16.w * TranslatedUIUtils.sizeFactor,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r * TranslatedUIUtils.sizeFactor),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : AppColors.lightColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryLight
                  : AppColors.textSecondary,
              size: 18.w * TranslatedUIUtils.sizeFactor,
            ),
            Gap(8.w * TranslatedUIUtils.sizeFactor),
            TranslatedUIUtils.buildTranslatableText(
              text: text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp * TranslatedUIUtils.sizeFactor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    String sourceLanguage = 'en',
    bool translateItems = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTranslatableText(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp * sizeFactor,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          sourceLanguage: sourceLanguage,
        ),
        Gap(8.h * sizeFactor),
        GetBuilder<TranslationController>(
          builder: (translationController) {
            return FutureBuilder<Map<String, String>>(
              future:
              translateItems && Get.isRegistered<TranslationController>()
                  ? _getTranslatedItems(items, sourceLanguage)
                  : Future.value(Map.fromIterables(items, items)),
              builder: (context, snapshot) {
                final translatedItems =
                    snapshot.data ?? Map.fromIterables(items, items);

                return DropdownButtonFormField<String>(
                  value: value.isEmpty ? null : value,
                  items: items.map((item) {
                    final translatedText = translatedItems[item] ?? item;
                    return DropdownMenuItem(
                      value: item, // Keep original value for logic
                      child: Text(
                        translatedText, // Show translated text
                        style:
                        GoogleFonts.poppins(fontSize: 16.sp * sizeFactor),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon,
                        color: AppColors.primaryLight,
                        size: 20.w * sizeFactor),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide: BorderSide(
                          color: AppColors.lightColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide: BorderSide(
                          color: AppColors.lightColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r * sizeFactor),
                      borderSide:
                      BorderSide(color: AppColors.primaryLight, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w * sizeFactor,
                        vertical: 16.h * sizeFactor),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }


  static Widget buildStatusContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    String sourceLanguage = 'en',
  }) {
    return Container(
      padding: EdgeInsets.all(20.w * sizeFactor),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r * sizeFactor),
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24.w * sizeFactor),
          Gap(16.w * sizeFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTranslatableText(
                  text: title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp * sizeFactor,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  sourceLanguage: sourceLanguage,
                ),
                Gap(4.h * sizeFactor),
                buildTranslatableText(
                  text: subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp * sizeFactor,
                    color: AppColors.textSecondary,
                  ),
                  sourceLanguage: sourceLanguage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<T?> showTranslatableDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    IconData? icon,
    Color? iconColor,
    Color? primaryButtonColor,
    Color? backgroundColor,
    bool barrierDismissible = true,
    String sourceLanguage = 'en',
    Widget? customContent,
    double? maxWidth,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? 400.w * sizeFactor,
            ),
            child: Card(
              elevation: 20,
              shadowColor: AppColors.primaryLight.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r * sizeFactor),
              ),
              color: backgroundColor ?? Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r * sizeFactor),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (backgroundColor ?? Colors.white),
                      (backgroundColor ?? Colors.white).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon and close button
                    Container(
                      padding: EdgeInsets.all(20.w * sizeFactor),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primaryLight)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r * sizeFactor),
                          topRight: Radius.circular(20.r * sizeFactor),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              padding: EdgeInsets.all(12.w * sizeFactor),
                              decoration: BoxDecoration(
                                color: (iconColor ?? AppColors.primaryLight)
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(50.r * sizeFactor),
                              ),
                              child: Icon(
                                icon,
                                color: iconColor ?? AppColors.primaryLight,
                                size: 28.w * sizeFactor,
                              ),
                            ),
                            Gap(16.w * sizeFactor),
                          ],
                          Expanded(
                            child: buildTranslatableText(
                              text: title,
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp * sizeFactor,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              sourceLanguage: sourceLanguage,
                            ),
                          ),
                          if (barrierDismissible)
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius:
                              BorderRadius.circular(20.r * sizeFactor),
                              child: Container(
                                padding: EdgeInsets.all(8.w * sizeFactor),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textSecondary,
                                  size: 20.w * sizeFactor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(20.w * sizeFactor),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (customContent != null)
                            customContent
                          else
                            buildTranslatableText(
                              text: message,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp * sizeFactor,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              sourceLanguage: sourceLanguage,
                            ),

                          Gap(24.h * sizeFactor),

                          // Action buttons
                          Row(
                            children: [
                              if (secondaryButtonText != null) ...[
                                Expanded(
                                  child: _buildDialogButton(
                                    text: secondaryButtonText,
                                    onPressed: onSecondaryPressed ??
                                            () => Navigator.of(context).pop(),
                                    backgroundColor: Colors.grey.shade100,
                                    textColor: AppColors.textSecondary,
                                    borderColor: Colors.grey.shade300,
                                    sourceLanguage: sourceLanguage,
                                  ),
                                ),
                                Gap(12.w * sizeFactor),
                              ],
                              Expanded(
                                child: _buildDialogButton(
                                  text: primaryButtonText ?? 'OK',
                                  onPressed: onPrimaryPressed ??
                                          () => Navigator.of(context).pop(),
                                  backgroundColor: primaryButtonColor ??
                                      AppColors.primaryLight,
                                  textColor: Colors.white,
                                  sourceLanguage: sourceLanguage,
                                ),
                              ),
                            ],
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
      },
    );
  }

  /// Helper method to build dialog buttons
  static Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    String sourceLanguage = 'en',
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryLight,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14.h * sizeFactor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r * sizeFactor),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: buildTranslatableText(
        text: text,
        style: GoogleFonts.poppins(
          fontSize: 16.sp * sizeFactor,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.white,
        ),
        sourceLanguage: sourceLanguage,
      ),
    );
  }

  /// Helper method to get translated text with proper cache handling
  static Future<String> _getTranslatedText(
      String text, String sourceLanguage) async {
    if (!Get.isRegistered<TranslationController>() || text.trim().isEmpty) {
      return text;
    }

    try {
      final controller = TranslationController.instance;
      if (!controller.isInitialized) {
        return text;
      }

      final targetLang = controller.currentLanguage?.code ?? 'en';
      if (targetLang == sourceLanguage) {
        return text;
      }

      // Use queued translation for better performance and cache management
      return await controller.queueTranslation(
        text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLang,
        originalText: sourceLanguage == 'en' ? text : null,
      );
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Fallback to original text
    }
  }

  /// Helper method to translate multiple items with cache optimization
  static Future<Map<String, String>> _getTranslatedItems(
      List<String> items, String sourceLanguage) async {
    if (!Get.isRegistered<TranslationController>() || items.isEmpty) {
      return Map.fromIterables(items, items);
    }

    try {
      final controller = TranslationController.instance;
      if (!controller.isInitialized) {
        return Map.fromIterables(items, items);
      }

      final targetLang = controller.currentLanguage?.code ?? 'en';
      if (targetLang == sourceLanguage) {
        return Map.fromIterables(items, items);
      }

      // Use batch translation for better performance
      final translations = await controller.translateBatch(
        items,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLang,
        useCache: true,
      );

      return translations;
    } catch (e) {
      debugPrint('Batch translation error: $e');
      return Map.fromIterables(items, items); // Fallback to original items
    }
  }

  /// Method to preload translations for better UX
  static Future<void> preloadTranslations({
    required List<String> texts,
    String sourceLanguage = 'en',
  }) async {
    if (!Get.isRegistered<TranslationController>() || texts.isEmpty) {
      return;
    }

    try {
      final controller = TranslationController.instance;
      if (!controller.isInitialized) {
        return;
      }

      final targetLang = controller.currentLanguage?.code ?? 'en';
      if (targetLang == sourceLanguage) {
        return;
      }

      // Preload translations in background
      unawaited(controller.translateBatch(
        texts,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLang,
        useCache: true,
      ));
    } catch (e) {
      debugPrint('Preload translation error: $e');
    }
  }

  /// Method to handle language change and refresh translations
  static void handleLanguageChange() {
    if (!Get.isRegistered<TranslationController>()) {
      return;
    }

    // Force rebuild of all GetBuilder widgets
    Get.find<TranslationController>().update();
  }
}

/// Extension to avoid blocking the main thread with unawaited futures
extension _FutureExtensions on Future {
  void get unawaited {}
}
