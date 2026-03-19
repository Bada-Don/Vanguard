import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Display Styles
  // Large text styles typically used for headers and hero elements

  TextStyle get display48BlackPublicSans => TextStyle(
    fontSize: 48.fSize,
    fontWeight: FontWeight.w900,
    fontFamily: 'Public Sans',
    color: appTheme.gray_100,
  );

  TextStyle get display48BoldPublicSans => TextStyle(
    fontSize: 48.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
    color: appTheme.gray_100,
  );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline30BoldPublicSans => TextStyle(
    fontSize: 30.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
    color: appTheme.gray_100,
  );

  TextStyle get headline24BoldPublicSans => TextStyle(
    fontSize: 24.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
    color: appTheme.gray_100,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20Black => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w900,
    color: appTheme.white_A700,
  );

  TextStyle get title20Bold => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    color: appTheme.gray_100,
  );

  TextStyle get title20BoldPublicSans => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
  );

  TextStyle get title18Bold => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    color: appTheme.cyan_A400,
  );

  TextStyle get title18BoldPublicSans => TextStyle(
    fontSize: 18.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
  );

  TextStyle get title16SemiBoldPublicSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Public Sans',
    color: appTheme.gray_100,
  );

  TextStyle get title16BoldPublicSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
  );

  TextStyle get title16RegularPublicSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_300,
  );

  TextStyle get title16MediumPublicSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_300,
  );

  TextStyle get title16SemiBold => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w600,
    color: appTheme.whiteCustom,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14BoldPublicSans => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
    color: appTheme.deep_orange_600,
  );

  TextStyle get body14MediumPublicSans => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_100,
  );

  TextStyle get body14Regular => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    color: appTheme.blue_gray_300,
  );

  TextStyle get body12RegularPublicSans => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_300,
  );

  TextStyle get body12Bold => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    color: appTheme.gray_100,
  );

  TextStyle get body12SemiBoldPublicSans => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Public Sans',
    color: appTheme.deep_orange_600,
  );

  TextStyle get body12MediumPublicSans => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Public Sans',
  );

  TextStyle get body12BoldPublicSans => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
  );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label11RegularPublicSans => TextStyle(
    fontSize: 11.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_300,
  );

  TextStyle get label11SemiBoldPublicSans => TextStyle(
    fontSize: 11.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Public Sans',
    color: appTheme.deep_orange_600,
  );

  TextStyle get label11BoldPublicSans => TextStyle(
    fontSize: 11.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
    color: appTheme.deep_orange_600,
  );

  TextStyle get label10BoldPublicSans => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Public Sans',
  );

  TextStyle get label10Bold => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w700,
    color: appTheme.blue_gray_300,
  );

  TextStyle get label10RegularPublicSans => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_300,
  );

  TextStyle get label10MediumPublicSans => TextStyle(
    fontSize: 10.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Public Sans',
    color: appTheme.blue_gray_300,
  );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get bodyTextPublicSans => TextStyle(fontFamily: 'Public Sans');
}
