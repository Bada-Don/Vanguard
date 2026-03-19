import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomEditText - A reusable text input field component with customizable styling,
 * border properties, background colors, and optional prefix icons.
 * 
 * Supports single-line and multi-line input with validation capabilities.
 * 
 * @param controller - TextEditingController for managing input text
 * @param placeholder - Hint text displayed when field is empty
 * @param validator - Function to validate input text
 * @param prefixIconPath - Optional path to prefix icon image
 * @param borderColor - Color of the input field border
 * @param borderWidth - Width of the input field border in pixels
 * @param borderRadius - Border radius of the input field
 * @param backgroundColor - Background fill color of the input field
 * @param textColor - Color of the input text
 * @param hintTextColor - Color of the placeholder/hint text
 * @param fontSize - Font size of the input text
 * @param fontWeight - Font weight of the input text
 * @param maxLines - Maximum number of lines for multi-line input
 * @param contentPadding - Internal padding of the input field
 * @param margin - External margin around the input field
 * @param keyboardType - Type of keyboard to display for input
 * @param textCapitalization - How to capitalize the input text
 * @param letterSpacing - Letter spacing for the input text
 * @param onTap - Callback function when the field is tapped
 */
class CustomEditText extends StatelessWidget {
  const CustomEditText({
    Key? key,
    this.controller,
    this.placeholder,
    this.validator,
    this.prefixIconPath,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.hintTextColor,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.contentPadding,
    this.margin,
    this.keyboardType,
    this.textCapitalization,
    this.letterSpacing,
    this.onTap,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? placeholder;
  final String? Function(String?)? validator;
  final String? prefixIconPath;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final double? letterSpacing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType ?? TextInputType.text,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        onTap: onTap,
        style: TextStyleHelper.instance.bodyTextPublicSans.copyWith(
          color: textColor ?? Color(0xFF94A3B8),
          letterSpacing: letterSpacing,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyleHelper.instance.bodyTextPublicSans.copyWith(
            color: hintTextColor ?? Color(0xFF94A3B8),
            letterSpacing: letterSpacing,
          ),
          prefixIcon: prefixIconPath != null
              ? Padding(
                  padding: EdgeInsets.all(12.h),
                  child: CustomImageView(
                    imagePath: prefixIconPath!,
                    height: 10.h,
                    width: 10.h,
                  ),
                )
              : null,
          filled: true,
          fillColor: backgroundColor ?? Color(0xFF2A1B15),
          contentPadding:
              contentPadding ??
              EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 12.h),
            borderSide: BorderSide(
              color: borderColor ?? Color(0x1333EC5B),
              width: borderWidth?.h ?? 1.h,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 12.h),
            borderSide: BorderSide(
              color: borderColor ?? Color(0x1333EC5B),
              width: borderWidth?.h ?? 1.h,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 12.h),
            borderSide: BorderSide(
              color: borderColor ?? Color(0x1333EC5B),
              width: borderWidth?.h ?? 1.h,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 12.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: borderWidth?.h ?? 1.h,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius?.h ?? 12.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: borderWidth?.h ?? 1.h,
            ),
          ),
        ),
      ),
    );
  }
}
