import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../common_widgets/app_button.dart';
import 'forgot_password_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSubmit});

  final Future<void> Function(String email, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get _isValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    // Permissive email regex allowing '+', subdomains, and modern TLDs
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email) && password.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both email and password.');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await widget.onSubmit(email, password);
      if (mounted) {
        debugPrint("Success signing in");
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Login error: $e");
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
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: const TextStyle(fontSize: 17),
              onChanged: (_) => setState(() {}),
              padding: EdgeInsets.zero,
            ),
            showBorder: true,
          ),
          _buildFormRow(
            context: context,
            label: 'Password',
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _passwordController,
                    placeholder: 'Required',
                    decoration: null,
                    textAlign: TextAlign.right,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 17),
                    onChanged: (_) => setState(() {}),
                    padding: EdgeInsets.zero,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  minimumSize: const Size(0, 0),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
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
        const SizedBox(height: 12),
        const ForgotPasswordButton(),
        const SizedBox(height: 24),
        AppButton(
          label: 'Sign In',
          onPressed: (_isLoading || !_isValid) ? null : _handleLogin,
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
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 17)),
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
