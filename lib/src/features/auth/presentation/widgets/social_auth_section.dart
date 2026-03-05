import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          icon: FontAwesomeIcons.apple,
          iconColor: CupertinoColors.label,
          label: 'Continue with Apple',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        _SocialButton(
          icon: FontAwesomeIcons.google,
          iconColor: const Color(0xFF4285F4),
          label: 'Continue with Google',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            FaIcon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            AppText(label, variant: AppTextVariant.bodyLarge, color: textColor),
          ],
        ),
      ),
    );
  }
}
