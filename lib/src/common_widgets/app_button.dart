import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';

/// Size variants for [AppButton].
enum AppButtonSize { small, medium, large }

/// A themed, responsive button that follows the app's iOS design system.
///
/// Sizes scale with the device's screen width relative to a 390 px reference
/// (iPhone 14), clamped between 85 % and 120 % so the button never becomes
/// too tiny on small phones or too bloated on large tablets.
///
/// Usage:
/// ```dart
/// AppButton(
///   label: 'Sign In',
///   onPressed: _handleLogin,
///   size: AppButtonSize.large,
///   isLoading: _isLoading,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.fullWidth = true,
    this.color,
    this.textColor,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isLoading;

  /// When true (default) the button stretches to fill its parent's width.
  final bool fullWidth;

  /// Fill colour — defaults to [AppColors.iosBlue].
  final Color? color;

  /// Label colour — defaults to white for filled, or [AppColors.iosBlue] for
  /// [outlined].
  final Color? textColor;

  /// When true the button has a transparent fill with a coloured border.
  final bool outlined;

  /// Optional leading icon.
  final IconData? icon;

  // ─── Base size tokens (at 390 px reference width) ──────────────────────────

  double get _baseHeight => switch (size) {
    AppButtonSize.small => 40,
    AppButtonSize.medium => 50,
    AppButtonSize.large => 56,
  };

  double get _baseFontSize => switch (size) {
    AppButtonSize.small => 14,
    AppButtonSize.medium => 16,
    AppButtonSize.large => 17,
  };

  double get _baseBorderRadius => switch (size) {
    AppButtonSize.small => 10,
    AppButtonSize.medium => 14,
    AppButtonSize.large => 16,
  };

  double get _baseIconSize => switch (size) {
    AppButtonSize.small => 14,
    AppButtonSize.medium => 16,
    AppButtonSize.large => 18,
  };

  FontWeight get _fontWeight => switch (size) {
    AppButtonSize.small => FontWeight.w500,
    AppButtonSize.medium => FontWeight.w600,
    AppButtonSize.large => FontWeight.w600,
  };

  // ─── Responsive scale factor ────────────────────────────────────────────────

  /// Normalises the current screen width against 390 px (iPhone 14).
  /// Clamped so the button never shrinks below base size (1.0) on small
  /// phones and never grows beyond 120% on wide screens.
  double _scale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 390.0).clamp(1.0, 1.20);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = _scale(context);

    final double height = _baseHeight * s;
    final double fontSize = _baseFontSize * s;
    final double borderRadius = _baseBorderRadius * s;
    final double iconSize = _baseIconSize * s;
    final double hPadding = (size == AppButtonSize.small ? 14.0 : 20.0) * s;

    final fillColor = color ?? AppColors.getAccentColor(context);
    final resolvedTextColor =
        textColor ?? (outlined ? fillColor : CupertinoColors.white);

    final bool disabled = onPressed == null || isLoading;

    Widget content = isLoading
        ? CupertinoActivityIndicator(
            color: resolvedTextColor,
            radius: fontSize * 0.65,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: .center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: resolvedTextColor),
                SizedBox(width: size == AppButtonSize.small ? 4 * s : 6 * s),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: _fontWeight,
                  color: resolvedTextColor,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          );

    Widget button = CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: disabled ? null : onPressed,
      pressedOpacity: 0.75,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        width: fullWidth ? double.infinity : null,
        padding: fullWidth
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: hPadding),
        decoration: BoxDecoration(
          color: outlined
              ? CupertinoColors.transparent
              : (disabled ? CupertinoColors.systemGrey4 : fillColor),
          borderRadius: BorderRadius.circular(borderRadius),
          border: outlined
              ? Border.all(
                  color: disabled ? CupertinoColors.systemGrey3 : fillColor,
                  width: 1.5,
                )
              : null,
          boxShadow: (!outlined && !disabled)
              ? [
                  BoxShadow(
                    color: fillColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: .center,
        child: content,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
