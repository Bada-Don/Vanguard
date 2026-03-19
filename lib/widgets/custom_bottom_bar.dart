import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomBottomBar - A flexible bottom navigation bar component
 * 
 * This widget creates a customizable bottom navigation bar with support for:
 * - Dynamic number of navigation items
 * - Icon and text display
 * - Active/inactive states
 * - Custom styling and colors
 * - Navigation callback handling
 * 
 * @param bottomBarItemList - List of navigation items to display
 * @param onChanged - Callback function when an item is tapped (returns index)
 * @param selectedIndex - Currently selected item index (default: 0)
 * @param backgroundColor - Background color of the bottom bar
 * @param borderColor - Top border color
 * @param activeColor - Color for active/selected items
 * @param inactiveColor - Color for inactive items
 * @param padding - Internal padding of the bottom bar
 */
class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({
    Key? key,
    required this.bottomBarItemList,
    required this.onChanged,
    this.selectedIndex = 0,
    this.backgroundColor,
    this.borderColor,
    this.activeColor,
    this.inactiveColor,
    this.padding,
  }) : super(key: key);

  /// List of bottom bar items with their properties
  final List<CustomBottomBarItem> bottomBarItemList;

  /// Current selected index of the bottom bar
  final int selectedIndex;

  /// Callback function triggered when a bottom bar item is tapped
  final Function(int) onChanged;

  /// Background color of the bottom bar
  final Color? backgroundColor;

  /// Top border color
  final Color? borderColor;

  /// Color for active/selected items
  final Color? activeColor;

  /// Color for inactive items
  final Color? inactiveColor;

  /// Internal padding of the bottom bar
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0x0CF2160F),
        border: Border(
          top: BorderSide(color: borderColor ?? Color(0x131E293B), width: 1.h),
        ),
      ),
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 42.h, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(bottomBarItemList.length, (index) {
          final isSelected = selectedIndex == index;
          final item = bottomBarItemList[index];

          return InkWell(
            onTap: () {
              onChanged(index);
            },
            child: _buildBottomBarItem(item, isSelected),
          );
        }),
      ),
    );
  }

  /// Builds individual bottom bar item with icon and text
  Widget _buildBottomBarItem(CustomBottomBarItem item, bool isSelected) {
    final itemActiveColor = activeColor ?? Color(0xFFEC5B13);
    final itemInactiveColor = inactiveColor ?? Color(0xFF64748B);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImageView(
          imagePath: isSelected ? (item.activeIcon ?? item.icon) : item.icon,
          height: 20.h,
          width: 20.h,
        ),
        if (item.title != null) ...[
          SizedBox(height: 4.h),
          Text(
            item.title!,
            style: TextStyleHelper.instance.label10BoldPublicSans
                .copyWith(
                  color: isSelected ? itemActiveColor : itemInactiveColor,
                  height: 1.2,
                )
                .copyWith(),
          ),
        ],
      ],
    );
  }
}

/// Item data model for custom bottom bar
class CustomBottomBarItem {
  CustomBottomBarItem({
    required this.icon,
    this.activeIcon,
    this.title,
    this.routeName,
  });

  /// Path to the default icon
  final String icon;

  /// Path to the active state icon (optional)
  final String? activeIcon;

  /// Title text shown below the icon (optional)
  final String? title;

  /// Route name for navigation (required for routing)
  final String? routeName;
}
