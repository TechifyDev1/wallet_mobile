import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/auth/repository/auth_repository.dart';
import 'package:wallet/src/features/main/presentation/pages/main_tabs.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/utils/storage.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_hero.dart';
import '../widgets/login_form.dart';
import 'register_page.dart';
import 'setup_pin_page.dart';

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
                  debugPrint('🔐 Login form submitted with email: $email');
                  try {
                    final repository = AuthRepository();
                    await repository.login(email: email, password: password);
                    debugPrint('✅ Login API call completed');

                    // Small delay to ensure token is persisted before making next request
                    await Future.delayed(const Duration(milliseconds: 100));
                    debugPrint(
                      '🔄 Calling userProvider.refresh() to fetch user data...',
                    );

                    try {
                      await ref.read(userProvider.notifier).refresh();
                      debugPrint('✅ userProvider.refresh() completed');
                    } catch (refreshError) {
                      debugPrint(
                        '❌ userProvider.refresh() failed: $refreshError',
                      );
                      debugPrint(
                        '⚠️ Continuing despite refresh error - user data may load later',
                      );
                      // Don't rethrow - continue to navigate anyway
                      // The user data will be fetched when MainTabs requests it
                    }

                    if (context.mounted) {
                      final isFirstTime =
                          await Storage.read("isFirstTime") == "true";
                      debugPrint('📋 isFirstTime: $isFirstTime');

                      if (isFirstTime) {
                        if (context.mounted) {
                          debugPrint('➡️ Navigating to SetupPinPage');
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (_) => const SetupPinPage(),
                            ),
                          );
                        }
                        return;
                      }
                      if (context.mounted) {
                        debugPrint('➡️ Navigating to MainTabs');
                        Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(builder: (_) => const MainTabs()),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('❌ Login form onSubmit error: $e');
                    rethrow; // Let the form handle the error display
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
