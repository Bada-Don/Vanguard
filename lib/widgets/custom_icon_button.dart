import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomIconButton - A highly customizable icon button widget with support for
 * background colors, borders, shadows, and flexible styling options.
 * 
 * @param iconPath - Path to the SVG/image icon (required)
 * @param onPressed - Callback function when button is pressed
 * @param height - Height of the button
 * @param width - Width of the button
 * @param padding - Internal padding around the icon
 * @param backgroundColor - Background color of the button
 * @param borderRadius - Corner radius of the button
 * @param borderColor - Border color of the button
 * @param borderWidth - Border width of the button
 * @param hasShadow - Whether to show shadow effect
 * @param shadowColor - Shadow color
 * @param shadowBlurRadius - Shadow blur radius
 * @param shadowOffset - Shadow offset
 * @param iconSize - Size of the icon inside the button
 */
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.iconPath,
    this.onPressed,
    this.height,
    this.width,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.hasShadow,
    this.shadowColor,
    this.shadowBlurRadius,
    this.shadowOffset,
    this.iconSize,
  }) : super(key: key);

  /// Path to the SVG/image icon
  final String iconPath;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Height of the button
  final double? height;

  /// Width of the button
  final double? width;

  /// Internal padding around the icon
  final EdgeInsetsGeometry? padding;

  /// Background color of the button
  final Color? backgroundColor;

  /// Corner radius of the button
  final double? borderRadius;

  /// Border color of the button
  final Color? borderColor;

  /// Border width of the button
  final double? borderWidth;

  /// Whether to show shadow effect
  final bool? hasShadow;

  /// Shadow color
  final Color? shadowColor;

  /// Shadow blur radius
  final double? shadowBlurRadius;

  /// Shadow offset
  final Offset? shadowOffset;

  /// Size of the icon inside the button
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48.h,
      width: width ?? 48.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0x1919EC5B),
        borderRadius: BorderRadius.circular(borderRadius ?? 8.h),
        border: borderColor != null && borderWidth != null
            ? Border.all(color: borderColor!, width: borderWidth!)
            : borderColor != null
            ? Border.all(color: borderColor!)
            : null,
        boxShadow: hasShadow == true
            ? [
                BoxShadow(
                  color: shadowColor ?? Color(0x3319EC5B),
                  blurRadius: shadowBlurRadius ?? 2.h,
                  offset: shadowOffset ?? Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: Material(
        color: appTheme.transparentCustom,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.h),
          onTap: onPressed,
          child: Padding(
            padding: padding ?? EdgeInsets.all(14.h),
            child: CustomImageView(
              imagePath: iconPath,
              height: iconSize ?? 20.h,
              width: iconSize ?? 20.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
