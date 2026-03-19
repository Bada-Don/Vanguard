import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomAppBar is a reusable AppBar component that supports various configurations
 * including leading icons, titles, subtitles, status indicators, and action buttons.
 * 
 * @param title - Main title text displayed in the AppBar
 * @param subtitle - Optional subtitle text displayed below the title  
 * @param leadingIcon - Path to the leading icon image
 * @param backgroundColor - Background color of the AppBar
 * @param titleColor - Color of the title text
 * @param subtitleColor - Color of the subtitle text
 * @param onLeadingPressed - Callback function when leading icon is pressed
 * @param showStatusIndicator - Whether to show the status indicator dot
 * @param statusIndicatorColor - Color of the status indicator dot
 * @param statusText - Text displayed next to the status indicator
 * @param statusTextColor - Color of the status text
 * @param actionIcons - List of action icon paths to display on the right
 * @param onActionPressed - Callback function when action icons are pressed
 * @param showShadow - Whether to show shadow effect on the AppBar
 * @param height - Custom height of the AppBar
 * @param showBorder - Whether to show bottom border
 */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    Key? key,
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.onLeadingPressed,
    this.showStatusIndicator,
    this.statusIndicatorColor,
    this.statusText,
    this.statusTextColor,
    this.actionIcons,
    this.onActionPressed,
    this.showShadow,
    this.height,
    this.showBorder,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final String? leadingIcon;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final VoidCallback? onLeadingPressed;
  final bool? showStatusIndicator;
  final Color? statusIndicatorColor;
  final String? statusText;
  final Color? statusTextColor;
  final List<String>? actionIcons;
  final Function(int)? onActionPressed;
  final bool? showShadow;
  final double? height;
  final bool? showBorder;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 64.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFFCC1A0F0A),
        boxShadow: (showShadow ?? false)
            ? [
                BoxShadow(
                  color: appTheme.colorFF8888,
                  blurRadius: 12.h,
                  offset: Offset(0, 4.h),
                ),
              ]
            : null,
        border: (showBorder ?? false)
            ? Border(
                bottom: BorderSide(color: appTheme.color1AEC5B, width: 1.h),
              )
            : null,
      ),
      child: AppBar(
        backgroundColor: appTheme.transparentCustom,
        elevation: 0,
        leading: leadingIcon != null ? _buildLeadingWidget() : null,
        title: _buildTitleWidget(),
        actions: _buildActionWidgets(),
        centerTitle: false,
        titleSpacing: leadingIcon != null ? 12.h : 16.h,
      ),
    );
  }

  Widget? _buildLeadingWidget() {
    if (leadingIcon == null) return null;

    return Padding(
      padding: EdgeInsets.all(8.h),
      child: IconButton(
        onPressed: onLeadingPressed,
        icon: CustomImageView(
          imagePath: leadingIcon!,
          height: 32.h,
          width: 32.h,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Row(
      children: [
        if (subtitle != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyleHelper.instance.title18BoldPublicSans
                        .copyWith(color: titleColor ?? Color(0xFFF1F5F9)),
                  ),
                Text(
                  subtitle!,
                  style: TextStyleHelper.instance.body12MediumPublicSans
                      .copyWith(color: subtitleColor ?? Color(0xFF94A3B8)),
                ),
              ],
            ),
          )
        else if (title != null)
          Expanded(
            child: Text(
              title!,
              style: TextStyleHelper.instance.title20BoldPublicSans.copyWith(
                color: titleColor ?? Color(0xFFF1F5F9),
              ),
            ),
          ),
        if (showStatusIndicator ?? false) ...[
          SizedBox(width: 34.h),
          _buildStatusIndicator(),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.h,
          height: 8.h,
          decoration: BoxDecoration(
            color: statusIndicatorColor ?? Color(0xFFFACC15),
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
        if (statusText != null) ...[
          SizedBox(width: 8.h),
          Text(
            statusText!,
            style: TextStyleHelper.instance.body12BoldPublicSans.copyWith(
              color: statusTextColor ?? Color(0xFFFACC15),
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget>? _buildActionWidgets() {
    if (actionIcons == null || actionIcons!.isEmpty) return null;

    return actionIcons!.asMap().entries.map((entry) {
      int index = entry.key;
      String iconPath = entry.value;

      return Padding(
        padding: EdgeInsets.only(right: 8.h),
        child: IconButton(
          onPressed: () => onActionPressed?.call(index),
          icon: CustomImageView(imagePath: iconPath, height: 40.h, width: 40.h),
          padding: EdgeInsets.zero,
        ),
      );
    }).toList();
  }
}
