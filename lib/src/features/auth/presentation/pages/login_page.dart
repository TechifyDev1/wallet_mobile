import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/auth/repository/auth_repository.dart';
import 'package:wallet/src/features/main/presentation/pages/main_tabs.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_hero.dart';
import '../widgets/login_form.dart';
import 'register_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                variant: AppTextVariant.bodyLarge,
                color: AppColors.getAccentColor(context),
              ),
            ],
          ),
        ),
        middle: Text('Sign In', style: TextStyle(color: textColor)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const .all(20),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 16),
              const AuthHero(
                title: 'Welcome Back',
                subtitle: 'Sign in to manage your digital assets.',
              ),
              const SizedBox(height: 40),
              LoginForm(
                onSubmit: (email, password) async {
                  final repository = AuthRepository();
                  await repository.login(email: email, password: password);
                  await ref.read(userProvider.notifier).refresh();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(builder: (_) => const MainTabs()),
                    );
                  }
                },
              ),
              // const SizedBox(height: 20),
              // const AuthDivider(),
              // const SizedBox(height: 20),
              // const SocialAuthSection(),
              const SizedBox(height: 32),
              AuthFooter(
                promptText: 'New to Wallet? ',
                actionText: 'Create Account',
                onAction: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
