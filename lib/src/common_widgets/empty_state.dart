import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import 'app_text.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.getSeparatorColor(context),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.getAccentColor(context).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            AppText(
              title,
              variant: AppTextVariant.bodyLarge,
              color: AppColors.getTextPrimary(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              subtitle,
              variant: AppTextVariant.bodySmall,
              color: AppColors.getTextSecondary(context),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                color: AppColors.getAccentColor(context),
                borderRadius: BorderRadius.circular(12),
                onPressed: onAction,
                child: AppText(
                  actionLabel!,
                  variant: AppTextVariant.bodyMedium,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
