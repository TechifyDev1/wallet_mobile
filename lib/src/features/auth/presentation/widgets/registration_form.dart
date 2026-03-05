import 'package:flutter/cupertino.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../pages/login_page.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key, required this.onSubmit});

  final Future<void> Function(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String phoneNumber,
  )
  onSubmit;

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  bool get _isValid {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty &&
        _emailController.text.trim().contains('@') &&
        _phoneNumberController.text.trim().length >= 7 &&
        _passwordController.text.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: .circular(12),
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
                label: 'First Name',
                child: CupertinoTextField(
                  controller: _firstNameController,
                  placeholder: 'John',
                  textAlign: TextAlign.right,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 17),
                  onChanged: (_) => setState(() {}),
                  padding: EdgeInsets.zero,
                  decoration: null,
                ),
                showBorder: true,
              ),
              _buildFormRow(
                context: context,
                label: 'Last Name',
                child: CupertinoTextField(
                  controller: _lastNameController,
                  placeholder: 'Doe',
                  textAlign: TextAlign.right,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 17),
                  onChanged: (_) => setState(() {}),
                  padding: EdgeInsets.zero,
                  decoration: null,
                ),
                showBorder: true,
              ),
              _buildFormRow(
                context: context,
                label: 'Username',
                child: CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'username',
                  textAlign: TextAlign.right,
                  autocorrect: false,
                  style: const TextStyle(fontSize: 17),
                  onChanged: (_) => setState(() {}),
                  padding: EdgeInsets.zero,
                  decoration: null,
                ),
                showBorder: true,
              ),
              _buildFormRow(
                context: context,
                label: 'Phone Number',
                child: CupertinoTextField(
                  controller: _phoneNumberController,
                  placeholder: '123456789',
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  style: const TextStyle(fontSize: 17),
                  onChanged: (_) => setState(() {}),
                  padding: EdgeInsets.zero,
                  decoration: null,
                ),
                showBorder: true,
              ),
              _buildFormRow(
                context: context,
                label: 'Email',
                child: CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'example@mail.com',
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: const TextStyle(fontSize: 17),
                  onChanged: (_) => setState(() {}),
                  padding: EdgeInsets.zero,
                  decoration: null,
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
                        textAlign: .right,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 17),
                        onChanged: (_) => setState(() {}),
                        decoration: null,
                      ),
                    ),
                    CupertinoButton(
                      padding: const .only(left: 8),
                      minimumSize: const Size(0, 0),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  _buildStrengthBar(_passwordController.text.isNotEmpty),
                  const SizedBox(width: 6),
                  _buildStrengthBar(_passwordController.text.length >= 2),
                  const SizedBox(width: 6),
                  _buildStrengthBar(_passwordController.text.length >= 4),
                  const SizedBox(width: 6),
                  _buildStrengthBar(_passwordController.text.length >= 6),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Must contain at least 6 characters.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.iosTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Create Account',
          onPressed: (_isLoading || !_isValid)
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  if (context.mounted) {
                    try {
                      await widget.onSubmit(
                        _firstNameController.text.trim(),
                        _lastNameController.text.trim(),
                        _usernameController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _phoneNumberController.text.trim().replaceAll(
                          RegExp(r'[\s-]'),
                          '',
                        ),
                      );
                      if (context.mounted) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => const LoginPage()),
                        );
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                      if (context.mounted) {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text(
                              'Error',
                              style: TextStyle(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                            content: Text(
                              e.toString(),
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
          size: AppButtonSize.large,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildStrengthBar(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: active
              ? CupertinoColors.activeGreen
              : CupertinoColors.systemGrey4,
          borderRadius: .circular(2),
        ),
      ),
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
