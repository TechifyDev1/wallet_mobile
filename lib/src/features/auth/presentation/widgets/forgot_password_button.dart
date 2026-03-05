import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .centerRight,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: onPressed ?? () {},
        child: AppText(
          'Forgot Password?',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.getAccentColor(context),
        ),
      ),
    );
  }
}
