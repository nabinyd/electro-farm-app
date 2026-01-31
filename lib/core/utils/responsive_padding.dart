// lib/core/utils/responsive_padding.dart
import 'package:flutter/material.dart';

class AppPadding {
  // Base spacing unit
  static const double _baseUnit = 8;

  // Spacing scale
  static double get xs => _baseUnit * 0.5; // 4
  static double get sm => _baseUnit * 1; // 8
  static double get md => _baseUnit * 2; // 16
  static double get lg => _baseUnit * 3; // 24
  static double get xl => _baseUnit * 4; // 32
  static double get xxl => _baseUnit * 6; // 48

  // Zero padding
  static const EdgeInsets zero = EdgeInsets.zero;

  // All sides
  static EdgeInsets get allXS => EdgeInsets.all(xs);
  static EdgeInsets get allSM => EdgeInsets.all(sm);
  static EdgeInsets get allMD => EdgeInsets.all(md);
  static EdgeInsets get allLG => EdgeInsets.all(lg);
  static EdgeInsets get allXL => EdgeInsets.all(xl);

  // Horizontal
  static EdgeInsets get hSM => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get hMD => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get hLG => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get hXL => EdgeInsets.symmetric(horizontal: xl);

  // Vertical
  static EdgeInsets get vSM => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get vMD => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get vLG => EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get vXL => EdgeInsets.symmetric(vertical: xl);

  // Combined
  static EdgeInsets get smAll =>
      EdgeInsets.symmetric(horizontal: sm, vertical: sm);
  static EdgeInsets get mdAll =>
      EdgeInsets.symmetric(horizontal: md, vertical: md);
  static EdgeInsets get lgAll =>
      EdgeInsets.symmetric(horizontal: lg, vertical: lg);

  // Screen
  static EdgeInsets get screen => EdgeInsets.all(md);
  static EdgeInsets get screenH => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get screenV => EdgeInsets.symmetric(vertical: md);

  // Components
  static EdgeInsets get card => EdgeInsets.all(md);
  static EdgeInsets get button =>
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static EdgeInsets get input =>
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static EdgeInsets get listTile =>
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
}

// Extension for easy context-based responsive padding
extension ResponsivePadding on BuildContext {
  EdgeInsets get screenPadding => MediaQuery.of(this).padding;
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  EdgeInsets get pagePadding {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) {
      return AppPadding.screen; // Mobile
    } else if (width < 900) {
      return AppPadding.allLG; // Tablet
    } else {
      return AppPadding.allXL; // Desktop
    }
  }
}
