import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';

/// Pinned footer shown at the bottom of auth pages with a CTA and security badge.
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.promptText,
    required this.actionText,
    this.onAction,
  });

  final String promptText;
  final String actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(context);

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          AppText(
            promptText,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.getTextSecondary(context),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onAction ?? () {},
            child: AppText(
              actionText,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.getAccentColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
