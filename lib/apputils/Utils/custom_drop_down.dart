import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final String? hintText;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isRequired;
  final bool enabled;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final double? borderRadius;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? itemTextStyle;
  final Color? dropdownBackgroundColor;
  final List<BoxShadow>? dropdownShadow;

  const CustomDropdownField({
    Key? key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isRequired = false,
    this.enabled = true,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.borderRadius,
    this.maxHeight,
    this.contentPadding,
    this.labelStyle,
    this.hintStyle,
    this.itemTextStyle,
    this.dropdownBackgroundColor,
    this.dropdownShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField2<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        labelStyle: labelStyle ??
            TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: borderColor ?? theme.dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: borderColor ?? theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: focusedBorderColor ?? theme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        filled: fillColor != null,
        fillColor: fillColor,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
      ),
      hint: Text(
        hintText ?? 'Select ${labelText.replaceAll('*', '').trim()}',
        style: hintStyle ??
            TextStyle(
              fontSize: 14.sp,
              color: theme.hintColor,
            ),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder(item),
                  style: itemTextStyle ??
                      TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          suffixIcon ?? Icons.keyboard_arrow_down_rounded,
          color: enabled ? theme.hintColor : theme.disabledColor,
        ),
        iconSize: 24.sp,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: maxHeight ?? 300.h,
        width: null,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          color: dropdownBackgroundColor ?? theme.scaffoldBackgroundColor,
          boxShadow: dropdownShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        elevation: 8,
        scrollbarTheme: ScrollbarThemeData(
          radius: Radius.circular(40.r),
          thickness: WidgetStateProperty.all(6.w),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
        offset: Offset(0, -8.h),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return theme.primaryColor.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
    );
  }
}
