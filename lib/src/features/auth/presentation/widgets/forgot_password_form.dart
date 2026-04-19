import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key, required this.onSubmit});

  final Future<void> Function(
    String email,
    String secretKey,
    String newPassword,
    String confirmPassword,
  )
  onSubmit;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureSecretKey = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  bool get _isValid {
    final email = _emailController.text.trim();
    final secretKey = _secretKeyController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    // Permissive email regex allowing '+', subdomains, and modern TLDs
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email) &&
        secretKey.isNotEmpty &&
        newPassword.isNotEmpty &&
        newPassword.length >= 6 &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _secretKeyController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final secretKey = _secretKeyController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        secretKey.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('Please fill in all fields.');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorDialog('Password must be at least 6 characters.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Passwords do not match.');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await widget.onSubmit(email, secretKey, newPassword, confirmPassword);
      if (mounted) {
        debugPrint("Password reset initiated");
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Forgot password error: $e");
        _showErrorDialog(e.toString());
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
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text(
          "Error",
          style: TextStyle(color: CupertinoColors.systemRed),
        ),
        content: Text(
          message,
          style: const TextStyle(color: CupertinoColors.systemRed),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              'OK',
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formCard = Container(
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFormRow(
            context: context,
            label: 'Email',
            child: CupertinoTextField(
              controller: _emailController,
              placeholder: 'name@example.com',
              decoration: null,
              textAlign: TextAlign.right,
              keyboardType: .emailAddress,
              autocorrect: false,
              style: const TextStyle(fontSize: 17),
              onChanged: (_) => setState(() {}),
              padding: EdgeInsets.zero,
            ),
            showBorder: true,
          ),
          _buildFormRow(
            context: context,
            label: 'Secret Key',
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _secretKeyController,
                    placeholder: 'Required',
                    decoration: null,
                    textAlign: TextAlign.right,
                    obscureText: _obscureSecretKey,
                    style: const TextStyle(fontSize: 17),
                    onChanged: (_) => setState(() {}),
                    padding: EdgeInsets.zero,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  minimumSize: const Size(0, 0),
                  onPressed: () =>
                      setState(() => _obscureSecretKey = !_obscureSecretKey),
                  child: Icon(
                    _obscureSecretKey
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    size: 20,
                    color: AppColors.iosTextSecondary,
                  ),
                ),
              ],
            ),
            showBorder: true,
          ),
          _buildFormRow(
            context: context,
            label: 'New Password',
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _newPasswordController,
                    placeholder: 'At least 6 characters',
                    decoration: null,
                    textAlign: TextAlign.right,
                    obscureText: _obscureNewPassword,
                    style: const TextStyle(fontSize: 17),
                    onChanged: (_) => setState(() {}),
                    padding: EdgeInsets.zero,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  minimumSize: const Size(0, 0),
                  onPressed: () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword,
                  ),
                  child: Icon(
                    _obscureNewPassword
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    size: 20,
                    color: AppColors.iosTextSecondary,
                  ),
                ),
              ],
            ),
            showBorder: true,
          ),
          _buildFormRow(
            context: context,
            label: 'Confirm Password',
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _confirmPasswordController,
                    placeholder: 'Confirm password',
                    decoration: null,
                    textAlign: TextAlign.right,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(fontSize: 17),
                    onChanged: (_) => setState(() {}),
                    padding: EdgeInsets.zero,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  minimumSize: const Size(0, 0),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  child: Icon(
                    _obscureConfirmPassword
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    size: 20,
                    color: AppColors.iosTextSecondary,
                  ),
                ),
              ],
            ),
            showBorder: false,
          ),
        ],
      ),
    );

    return Column(
      children: [
        formCard,
        const SizedBox(height: 24),
        AppButton(
          label: 'Reset Password',
          onPressed: (_isLoading || !_isValid) ? null : _handleSubmit,
          size: AppButtonSize.large,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildFormRow({
    required BuildContext context,
    required String label,
    required Widget child,
    required bool showBorder,
  }) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: AppColors.iosSeparator.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: AppText(label, variant: AppTextVariant.bodyLarge),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
