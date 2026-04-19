import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';
import '../pages/forgot_password_page.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .centerRight,
      child: CupertinoButton(
        padding: const .symmetric(horizontal: 4),
        onPressed:
            onPressed ??
            () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const ForgotPasswordPage()),
              );
            },
        child: AppText(
          'Forgot Password?',
          variant: .bodyMedium,
          color: AppColors.getAccentColor(context),
        ),
      ),
    );
  }
}
