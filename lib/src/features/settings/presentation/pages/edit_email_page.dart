import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/user/presentation/provider/user_provider.dart';

class EditEmailPage extends ConsumerStatefulWidget {
  const EditEmailPage({super.key});

  @override
  ConsumerState<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends ConsumerState<EditEmailPage> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value?.user;
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return email.isNotEmpty &&
        password.isNotEmpty &&
        emailRegex.hasMatch(email);
  }

  Future<void> _handleSave() async {
    if (!_isValid) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(userProvider.notifier)
          .changeEmail(
            newEmail: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.getCardColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.left_chevron,
                size: 20,
                color: AppColors.getAccentColor(context),
              ),
              const SizedBox(width: 4),
              AppText(
                'Back',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getAccentColor(context),
              ),
            ],
          ),
        ),
        middle: const AppText('Email', variant: AppTextVariant.bodyLarge),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isValid ? _handleSave : null,
                child: AppText(
                  'Save',
                  variant: AppTextVariant.bodyMedium,
                  color: _isValid
                      ? AppColors.getAccentColor(context)
                      : CupertinoColors.inactiveGray,
                ),
              ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              color: AppColors.getCardColor(context),
              child: Column(
                children: [
                  _buildField(
                    'New Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      height: 0.5,
                      color: AppColors.getSeparatorColor(context),
                    ),
                  ),
                  _buildField(
                    'Password',
                    _passwordController,
                    isPassword: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppText(
                'Changing your email address will also change your primary login identifier. For security, you will be automatically logged out and must sign in again with your new email.\n\nYou must provide your current password to authorize this change.',
                variant: AppTextVariant.caption,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: isPassword,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextPrimary(context),
              ),
              placeholderStyle: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondary(context),
              ),
              padding: EdgeInsets.zero,
              onChanged: (_) => setState(() {}),
              autofocus: !isPassword,
            ),
          ),
        ],
      ),
    );
  }
}
