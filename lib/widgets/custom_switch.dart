import 'package:flutter/material.dart';
import '../core/app_export.dart';

/**
 * CustomSwitch - A reusable switch component with customizable styling and responsive design
 * 
 * @param value - Current boolean state of the switch (required)
 * @param onChanged - Callback function triggered when switch state changes (required)
 * @param activeColor - Color when switch is in active/on state
 * @param inactiveThumbColor - Color of the thumb when switch is inactive
 * @param inactiveTrackColor - Color of the track when switch is inactive
 * @param width - Custom width for the switch
 * @param height - Custom height for the switch
 */
class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.width,
    this.height,
  }) : super(key: key);

  /// Current boolean state of the switch
  final bool value;

  /// Callback function triggered when switch state changes
  final ValueChanged<bool>? onChanged;

  /// Color when switch is in active/on state
  final Color? activeColor;

  /// Color of the thumb when switch is inactive
  final Color? inactiveThumbColor;

  /// Color of the track when switch is inactive
  final Color? inactiveTrackColor;

  /// Custom width for the switch
  final double? width;

  /// Custom height for the switch
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 51.h,
      height: height ?? 31.h,
      child: Transform.scale(
        scale: (width != null || height != null) ? 1.0 : 1.h,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor ?? Color(0xFF52D1C6),
          inactiveThumbColor: inactiveThumbColor ?? Color(0xFFFFFFFF),
          inactiveTrackColor: inactiveTrackColor ?? Color(0xFFE0E0E0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
