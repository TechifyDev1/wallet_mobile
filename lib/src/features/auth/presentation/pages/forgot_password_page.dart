import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';
import '../../repository/auth_repository.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_hero.dart';
import '../widgets/forgot_password_form.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(context);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg.withValues(alpha: 0.8),
        border: null,
        leading: CupertinoButton(
          padding: .zero,
          onPressed: () => Navigator.of(context).maybePop(),
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(
                CupertinoIcons.chevron_left,
                color: AppColors.getAccentColor(context),
              ),
              AppText(
                'Back',
                variant: .bodyLarge,
                color: AppColors.getAccentColor(context),
              ),
            ],
          ),
        ),
        middle: Text('Reset Password', style: TextStyle(color: textColor)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const .all(20),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 16),
              const AuthHero(
                title: 'Reset Password',
                subtitle:
                    'Verify your identity with your email and secret key to reset your password.',
              ),
              const SizedBox(height: 40),
              ForgotPasswordForm(
                onSubmit:
                    (email, secretKey, newPassword, confirmPassword) async {
                      final repository = AuthRepository();
                      try {
                        await repository.forgotPassword(
                          email: email,
                          secretKey: secretKey,
                          newPassword: newPassword,
                        );
                        if (context.mounted) {
                          _showSuccessDialog();
                        }
                      } catch (e) {
                        debugPrint("Error: $e");
                        rethrow;
                      }
                    },
              ),
              const SizedBox(height: 32),
              AuthFooter(
                promptText: 'Remember your password? ',
                actionText: 'Sign In',
                onAction: () {
                  Navigator.of(
                    context,
                  ).push(CupertinoPageRoute(builder: (_) => const LoginPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const AppText('Success'),
        content: const AppText(
          'Password reset successful! Please log in with your new password.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const AppText('OK'),
          ),
        ],
      ),
    );
  }
}
