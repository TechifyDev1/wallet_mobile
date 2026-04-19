import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_text.dart';
import '../../repository/auth_repository.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_hero.dart';
import '../widgets/registration_form.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sign Up'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).maybePop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const .all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const AuthHero(
                title: 'Create Account',
                subtitle: 'Bank-Level Security. Built for You.',
                iconShape: BoxShape.circle,
              ),
              const SizedBox(height: 32),
              RegistrationForm(
                onSubmit:
                    (
                      firstName,
                      lastName,
                      username,
                      email,
                      password,
                      phoneNumber,
                      secretKey,
                    ) async {
                      final repository = AuthRepository();
                      await repository.register(
                        firstName: firstName,
                        lastName: lastName,
                        username: username,
                        email: email,
                        password: password,
                        phoneNumber: phoneNumber,
                        secretKey: secretKey,
                      );
                    },
              ),
              // const SizedBox(height: 32),
              // const AuthDivider(label: 'OR SIGN UP WITH'),
              // const SizedBox(height: 24),
              // const SocialAuthSection(),
              const SizedBox(height: 32),
              AuthFooter(
                promptText: 'Already have an account? ',
                actionText: 'Log In',
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
}
