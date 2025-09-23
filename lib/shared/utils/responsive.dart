import 'package:flutter/material.dart';

class Responsive {
  // Base design dimensions (iPhone 12/13 Pro size)
  static const double baseWidth = 390.0;
  static const double baseHeight = 844.0;

  static double getScale(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scaleX = screenSize.width / baseWidth;
    final scaleY = screenSize.height / baseHeight;
    // Use the smaller scale to prevent overflow
    return scaleX < scaleY ? scaleX : scaleY;
  }

  static double scaleWidth(BuildContext context, double width) {
    return width * getScale(context);
  }

  static double scaleHeight(BuildContext context, double height) {
    return height * getScale(context);
  }

  static double scaleFont(BuildContext context, double fontSize) {
    return fontSize * getScale(context);
  }

  static EdgeInsets scalePadding(BuildContext context, EdgeInsets padding) {
    final scale = getScale(context);
    return EdgeInsets.only(
      left: padding.left * scale,
      top: padding.top * scale,
      right: padding.right * scale,
      bottom: padding.bottom * scale,
    );
  }

  static EdgeInsets scalePaddingAll(BuildContext context, double padding) {
    final scaledPadding = padding * getScale(context);
    return EdgeInsets.all(scaledPadding);
  }

  static EdgeInsets scalePaddingSymmetric(BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    final scale = getScale(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal * scale,
      vertical: vertical * scale,
    );
  }

  static BorderRadius scaleBorderRadius(BuildContext context, BorderRadius radius) {
    final scale = getScale(context);
    return BorderRadius.only(
      topLeft: Radius.circular(radius.topLeft.x * scale),
      topRight: Radius.circular(radius.topRight.x * scale),
      bottomLeft: Radius.circular(radius.bottomLeft.x * scale),
      bottomRight: Radius.circular(radius.bottomRight.x * scale),
    );
  }

  static BorderRadius scaleBorderRadiusAll(BuildContext context, double radius) {
    return BorderRadius.circular(radius * getScale(context));
  }

  // Check if screen is small (for additional responsive adjustments)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 700;
  }

  // Check if screen is very small (for minimal layouts)
  static bool isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 600;
  }
}
