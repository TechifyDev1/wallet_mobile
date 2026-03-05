import 'package:flutter/cupertino.dart';

class AppColors {
  // Light Theme Colors
  static const Color iosBlue = CupertinoColors.activeBlue;
  static const Color iosBg = Color(0xFFF2F2F7);
  static const Color iosCard = Color(0xFFFFFFFF);
  static const Color iosSeparator = Color(0xFFE5E7EB);
  static const Color iosSeparatorDark = Color(0xFF38383A);
  static const Color iosTextPrimary = Color(0xFF000000);
  static const Color iosTextPrimaryDark = Color(0xFFFFFFFF);
  static const Color iosTextSecondary = Color(0xFF8E8E93);
  static const Color iosTextSecondaryDark = Color(0xFFA1A1AA);

  // Dark Theme Colors (Gold Theme)
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color richGold = Color(0xFFB8860B);
  static const Color metallicGold = Color(0xFFE5C100);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color inputDark = Color(0xFF1C1C1E);
  static const Color iosGray = Color(0xFF8E8E93);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5E1A4), Color(0xFFD4AF37), Color(0xFFB8860B)],
    stops: [0.0, 0.5, 1.0],
  );

  static Color getBackgroundColor(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.light ? iosBg : backgroundDark;
  }

  static Color getCardColor(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.light ? iosCard : surfaceDark;
  }

  static Color getTextPrimary(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.light ? iosTextPrimary : iosTextPrimaryDark;
  }

  static Color getTextSecondary(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.light
        ? iosTextSecondary
        : iosTextSecondaryDark;
  }

  static Color getSeparatorColor(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.light ? iosSeparator : iosSeparatorDark;
  }

  /// Returns the primary interactive/accent color.
  /// Gold in dark mode, iOS blue in light mode.
  static Color getAccentColor(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.light
        ? const Color(0xFF137FEC)
        : primaryGold;
  }
}
