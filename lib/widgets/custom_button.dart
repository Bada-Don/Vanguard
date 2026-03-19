import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * A customizable button widget that supports text, icons, and various styling options.
 * 
 * Features:
 * - Configurable background color and text color
 * - Support for left or right positioned icons
 * - Customizable width and styling
 * - Built-in shadow and border radius support
 * 
 * @param text - The text to display on the button
 * @param width - The width of the button (required)
 * @param onPressed - Callback function when button is pressed
 * @param backgroundColor - Background color of the button
 * @param textColor - Color of the button text
 * @param iconPath - Path to the icon image
 * @param iconPosition - Position of the icon (left or right)
 * @param borderRadius - Border radius of the button
 * @param elevation - Shadow elevation of the button
 */
class CustomButton extends StatelessWidget {
  final String? text;
  final double width;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String? iconPath;
  final CustomButtonIconPosition? iconPosition;
  final double? borderRadius;
  final double? elevation;

  const CustomButton({
    Key? key,
    this.text,
    required this.width,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconPath,
    this.iconPosition,
    this.borderRadius,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? appTheme.deep_orange_600,
          elevation: elevation ?? 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((borderRadius ?? 12.0).h),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 18.h),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    final hasIcon = iconPath != null && iconPath!.isNotEmpty;
    final showLeftIcon =
        hasIcon && iconPosition == CustomButtonIconPosition.left;
    final showRightIcon =
        hasIcon && iconPosition == CustomButtonIconPosition.right;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLeftIcon) ...[
          CustomImageView(imagePath: iconPath!, height: 24.h, width: 24.h),
          SizedBox(width: 8.h),
        ],
        Flexible(
          child: Text(
            text ?? '',
            style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(
              color: textColor ?? appTheme.whiteCustom,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (showRightIcon) ...[
          SizedBox(width: 8.h),
          CustomImageView(imagePath: iconPath!, height: 20.h, width: 20.h),
        ],
      ],
    );
  }
}

enum CustomButtonIconPosition { left, right }
