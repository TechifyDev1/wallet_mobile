import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/features/auth/repository/auth_repository.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    return currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        newPassword.length >= 6 &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  Future<void> _handleSave() async {
    if (!_isValid) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (newPassword.length < 6) {
      _showErrorDialog('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repository = AuthRepository();
      await repository.resetPassword(
        existingPassword: currentPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        _showSuccessDialog('Password changed successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
        middle: const AppText(
          'Change Password',
          variant: AppTextVariant.bodyLarge,
        ),
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
                  _buildPasswordField(
                    'Current',
                    _currentPasswordController,
                    _obscureCurrentPassword,
                    (value) => setState(() => _obscureCurrentPassword = value),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      height: 0.5,
                      color: AppColors.getSeparatorColor(context),
                    ),
                  ),
                  _buildPasswordField(
                    'New Password',
                    _newPasswordController,
                    _obscureNewPassword,
                    (value) => setState(() => _obscureNewPassword = value),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      height: 0.5,
                      color: AppColors.getSeparatorColor(context),
                    ),
                  ),
                  _buildPasswordField(
                    'Confirm',
                    _confirmPasswordController,
                    _obscureConfirmPassword,
                    (value) => setState(() => _obscureConfirmPassword = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppText(
                'Update your password to keep your account secure. Use a strong password with at least 6 characters.',
                variant: AppTextVariant.caption,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    Function(bool) onToggleObscure,
  ) {
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
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                CupertinoTextField(
                  controller: controller,
                  obscureText: obscure,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextPrimary(context),
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextSecondary(context),
                  ),
                  padding: const EdgeInsets.only(right: 40),
                  onChanged: (_) => setState(() {}),
                  autofocus: false,
                  decoration: null,
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => onToggleObscure(!obscure),
                  child: Icon(
                    obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    size: 18,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
