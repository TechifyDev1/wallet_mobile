import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';

/// Hero header shown on auth pages with an icon, title and subtitle.
class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.iconShape = BoxShape.rectangle,
  });

  final String title;
  final String subtitle;
  final BoxShape iconShape;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.getAccentColor(context),
            shape: iconShape,
            borderRadius: iconShape == BoxShape.rectangle
                ? BorderRadius.circular(14)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.getAccentColor(context).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            CupertinoIcons.square_stack_3d_down_right_fill,
            color: CupertinoColors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        AppText(title, variant: AppTextVariant.displayLarge),
        const SizedBox(height: 8),
        AppText(
          subtitle,
          variant: AppTextVariant.bodyLarge,
          color: AppColors.getTextSecondary(context),
        ),
      ],
    );
  }
}
