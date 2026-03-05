import 'package:flutter/cupertino.dart';

import '../core/constants/app_colors.dart';

/// A responsive text widget that follows the app's type scale.
///
/// Font sizes scale with the device's screen width relative to a 390 px
/// reference (iPhone 14), clamped between 85 % and 120 %.
///
/// The system text-scale factor (accessibility large text) is also respected,
/// but clamped to 1.3 × so display sizes can't overflow their containers.
///
/// Usage:
/// ```dart
/// AppText('Welcome Back', variant: AppTextVariant.displayLarge)
/// AppText('Sign in.', variant: AppTextVariant.bodyLarge,
///         color: AppColors.iosTextSecondary)
/// ```
class AppText extends StatelessWidget {
  final String text;

  final AppTextVariant variant;

  /// Override colour. When null a sensible default is chosen per-variant.
  final Color? color;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Line-height multiplier (e.g. 1.5). Defaults to variant default.
  final double? height;

  /// Override font weight. When null variant default is used.
  final FontWeight? fontWeight;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyLarge,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.fontWeight,
  });

  // ─── Base style tokens (at 390 px reference width) ─────────────────────────

  double get _baseFontSize => switch (variant) {
    AppTextVariant.displayLarge => 34,
    AppTextVariant.displaySmall => 26,
    AppTextVariant.bodyLarge => 17,
    AppTextVariant.bodyMedium => 15,
    AppTextVariant.bodySmall => 14,
    AppTextVariant.caption => 12,
  };

  double? get _defaultHeight => switch (variant) {
    AppTextVariant.bodyLarge => 1.5,
    AppTextVariant.bodyMedium => 1.45,
    _ => null,
  };

  FontWeight get _fontWeight => switch (variant) {
    AppTextVariant.displayLarge => FontWeight.w700,
    AppTextVariant.displaySmall => FontWeight.w800,
    AppTextVariant.bodyLarge => FontWeight.w400,
    AppTextVariant.bodyMedium => FontWeight.w500,
    AppTextVariant.bodySmall => FontWeight.w500,
    AppTextVariant.caption => FontWeight.w400,
  };

  double get _letterSpacing => switch (variant) {
    AppTextVariant.displayLarge => -0.5,
    AppTextVariant.displaySmall => -0.3,
    _ => 0,
  };

  // ─── Responsive helpers ─────────────────────────────────────────────────────

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Combined scale: screen-width factor × clamped accessibility factor
    final double fontSize =
        _baseFontSize * _widthScale(context) * _textScale(context);

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      // Disable Flutter's automatic text scaling because we handle it manually
      // above with our clamped factor.
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight ?? _fontWeight,
        letterSpacing: _letterSpacing,
        height: height ?? _defaultHeight,
        color: _resolveColor(context),
      ),
    );
  }

  // ─── Colour ─────────────────────────────────────────────────────────────────

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    return switch (variant) {
      AppTextVariant.caption ||
      AppTextVariant.bodySmall => AppColors.getTextSecondary(context),
      _ => AppColors.getTextPrimary(context),
    };
  }

  /// Clamps the device's accessibility text-scale factor to 1.3 ×.
  /// Display-size variants get a tighter cap (1.15 ×) to protect layouts.
  double _textScale(BuildContext context) {
    final isDisplay =
        variant == AppTextVariant.displayLarge ||
        variant == AppTextVariant.displaySmall;
    final systemScale = MediaQuery.textScalerOf(context).scale(1.0);
    return systemScale.clamp(1.0, isDisplay ? 1.15 : 1.3);
  }

  /// Screen-width scale factor normalised against 390 px (iPhone 14).
  /// Clamped so text never shrinks below base size (1.0) on small phones
  /// and never grows beyond 120% on wide screens.
  double _widthScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 390.0).clamp(1.0, 1.20);
  }
}

/// Semantic text size variants.
enum AppTextVariant {
  /// 34 sp / bold — page & hero titles
  displayLarge,

  /// 26 sp / extrabold — screen headings (e.g. Setup PIN)
  displaySmall,

  /// 17 sp / regular — main body copy, nav labels
  bodyLarge,

  /// 15 sp / medium — subtitles, footer prompts
  bodyMedium,

  /// 13 sp / medium — field labels, captions, inline badges
  bodySmall,

  /// 11 sp / regular — helper text, disclaimers
  caption,
}
