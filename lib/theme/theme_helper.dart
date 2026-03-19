import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get deep_orange_600 => Color(0xFFEC5B13);
  Color get blue_gray_100 => Color(0xFFCBD5E1);
  Color get gray_100 => Color(0xFFF1F5F9);
  Color get amber_500 => Color(0xFFFACC15);
  Color get gray_900 => Color(0xFF1A0F0A);
  Color get gray_900_01 => Color(0xFF2A1B15);
  Color get blue_gray_300 => Color(0xFF94A3B8);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get blue_gray_500 => Color(0xFF64748B);
  Color get blue_gray_800 => Color(0xFF334155);
  Color get black_900_3f => Color(0x3F000000);
  Color get green_A700 => Color(0xFF22C55E);
  Color get black_900 => Color(0xFF160F0B);
  Color get blue_gray_900 => Color(0xFF1E293B);
  Color get orange_900_3f => Color(0x3FEA580C);
  Color get gray_900_02 => Color(0xFF221610);
  Color get red_700 => Color(0xFFDC2626);
  Color get black_900_01 => Color(0xFF120A07);
  Color get cyan_A400 => Color(0xFF00F2FF);
  Color get gray_900_03 => Color(0xFF0F172A);
  Color get red_A400 => Color(0xFFFF003C);
  Color get pink_900 => Color(0xFF7F1D1D);
  Color get gray_600 => Color(0xFF6B7280);
  Color get gray_900_04 => Color(0xFF1A120E);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get redCustom => Colors.red;
  Color get greyCustom => Colors.grey;
  Color get color19EC5B => Color(0x19EC5B13);
  Color get color4CEC5B => Color(0x4CEC5B13);
  Color get color0CEC5B => Color(0x0CEC5B13);
  Color get color33EC5B => Color(0x33EC5B13);
  Color get colorCC1A0F => Color(0xCC1A0F0A);
  Color get color1919EC => Color(0x1919EC5B);
  Color get colorCC120A => Color(0xCC120A07);
  Color get color33FF00 => Color(0x33FF003C);
  Color get colorFF8888 => Color(0xFF888888);
  Color get color4CFF00 => Color(0x4CFF003C);
  Color get color19FF00 => Color(0x19FF003C);
  Color get color66FF00 => Color(0x66FF003C);
  Color get color00120A => Color(0x00120A07);
  Color get color0CE512 => Color(0x0CE5120A);
  Color get color131E29 => Color(0x131E293B);
  Color get color4CFFFF => Color(0x4CFFFFFF);
  Color get color0CFFFF => Color(0x0CFFFFFF);
  Color get colorFF52D1 => Color(0xFF52D1C6);
  Color get colorFFFF88 => Color(0xFFFF8888);
  Color get color6622C5 => Color(0x6622C55E);
  Color get color3333EC => Color(0x3333EC5B);
  Color get color4C1E29 => Color(0x4C1E293B);
  Color get color66EC5B => Color(0x66EC5B13);
  Color get color00160F => Color(0x00160F0B);
  Color get colorCC160F => Color(0xCC160F0B);
  Color get color3FEC5B => Color(0x3FEC5B13);
  Color get colorFFE0E0 => Color(0xFFE0E0E0);
  Color get color7F2216 => Color(0x7F221610);
  Color get color0C1E29 => Color(0x0C1E293B);
  Color get color1AEC5B => Color(0x1AEC5B13);
  Color get color0CF216 => Color(0x0CF2160F);
  Color get color1333EC => Color(0x1333EC5B);
  Color get color3319EC => Color(0x3319EC5B);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
