import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../repository/auth_repository.dart';

class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  static const int _pinLength = 6;

  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _pinFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _showPin = false;
  bool _isLoading = false;

  String get _pin => _pinController.text;
  String get _confirmPin => _confirmController.text;

  bool get _pinComplete => _pin.length == _pinLength;
  bool get _confirmComplete => _confirmPin.length == _pinLength;
  bool get _confirmActive => _confirmFocus.hasFocus;
  bool get _pinActive => _pinFocus.hasFocus;

  bool get _canConfirm =>
      _pinComplete && _confirmComplete && _pin == _confirmPin;

  @override
  void initState() {
    super.initState();

    _pinController.addListener(_onPinChanged);
    _confirmController.addListener(_onConfirmChanged);
    _pinFocus.addListener(() => setState(() {}));
    _confirmFocus.addListener(() => setState(() {}));

    // Open the keyboard on the PIN field when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocus.requestFocus();
    });
  }

  void _onPinChanged() {
    final sanitised = _pin.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitised != _pin) {
      _pinController.value = TextEditingValue(
        text: sanitised,
        selection: TextSelection.collapsed(offset: sanitised.length),
      );
      return; // listener fires again with corrected value
    }
    setState(() {});

    // Auto-advance to confirm when PIN is filled
    if (_pin.length == _pinLength && _pinFocus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) {
          _confirmFocus.requestFocus();
        }
      });
    }
  }

  void _onConfirmChanged() {
    final sanitised = _confirmPin.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitised != _confirmPin) {
      _confirmController.value = TextEditingValue(
        text: sanitised,
        selection: TextSelection.collapsed(offset: sanitised.length),
      );
      return;
    }
    setState(() {});
  }

  /// Tap on the Enter-PIN row → focus the pin field, clear confirm so the
  /// user can start the confirm step fresh after editing.
  void _focusPin() {
    _confirmFocus.unfocus();
    _confirmController.clear();
    _pinFocus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// Tap on the Confirm-PIN row → only allowed when the first PIN is filled.
  void _focusConfirm() {
    if (!_pinComplete) return;
    _pinFocus.unfocus();
    _confirmFocus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  Future<void> _onConfirm() async {
    if (!_canConfirm || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await AuthRepository().createPin(pin: _pin);
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const AppText("Error", variant: .displaySmall),
            content: AppText(e.toString()),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(ctx).pop(),
                child: const AppText('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const AppText('PIN Set'),
        content: const AppText(
          'Your transaction PIN has been set successfully.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {},
            child: const AppText('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _confirmController.removeListener(_onConfirmChanged);
    _pinController.dispose();
    _confirmController.dispose();
    _pinFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBackgroundColor(context);
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;

    // Two hidden system-keyboard text fields stacked at 0-height
    final hiddenFields = SizedBox(
      height: 1,
      child: Opacity(
        opacity: 0,
        child: IgnorePointer(
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _pinController,
                  focusNode: _pinFocus,
                  keyboardType: TextInputType.number,
                  maxLength: _pinLength,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_pinLength),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTextField(
                  controller: _confirmController,
                  focusNode: _confirmFocus,
                  keyboardType: TextInputType.number,
                  maxLength: _pinLength,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_pinLength),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

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
        middle: AppText(
          'Setup PIN',
          variant: AppTextVariant.bodyLarge,
          color: textColor,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            hiddenFields,
            Expanded(
              child: SingleChildScrollView(
                padding: const .fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: .center,
                  children: [
                    // ── Title & subtitle ────────────────────────
                    AppText(
                      'Setup Transaction PIN',
                      variant: AppTextVariant.displaySmall,
                      color: textColor,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Create a secure 6-digit PIN to authorize\ntransfers and manage your wallet.',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.iosTextSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // ── Enter PIN ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          'Enter PIN',
                          variant: AppTextVariant.bodySmall,
                          color: textColor,
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () => setState(() => _showPin = !_showPin),
                          child: Row(
                            children: [
                              Icon(
                                _showPin
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_fill,
                                color: AppColors.iosBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                _showPin ? 'Hide' : 'Show',
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.iosBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Tapping this row re-focuses the pin field
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _focusPin,
                      child: _PinDots(
                        digits: _pin.split(''),
                        showPin: _showPin,
                        active: _pinActive,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Confirm PIN ──────────────────────────────
                    Opacity(
                      opacity: _pinComplete ? 1.0 : 0.45,
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          AppText(
                            'Confirm PIN',
                            variant: AppTextVariant.bodySmall,
                            color: textColor,
                          ),
                          const SizedBox(height: 10),
                          // Tapping this row focuses the confirm field
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _focusConfirm,
                            child: _PinDots(
                              digits: _confirmPin.split(''),
                              showPin: _showPin,
                              active: _confirmActive,
                              isDark: isDark,
                              mismatch: _confirmComplete && _pin != _confirmPin,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Confirm button ───────────────────────────
                    AppButton(
                      label: 'Confirm PIN',
                      onPressed: _canConfirm ? _onConfirm : null,
                      size: AppButtonSize.large,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.digits,
    required this.showPin,
    required this.active,
    required this.isDark,
    this.mismatch = false,
  });

  final List<String> digits;
  final bool showPin;
  final bool active;
  final bool isDark;
  final bool mismatch;

  static const int _total = 6;

  @override
  Widget build(BuildContext context) {
    final filled = digits.length;

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: List.generate(_total, (i) {
        final isFilled = i < filled;
        final isNext = i == filled && active;

        final Color borderColor;
        if (mismatch) {
          borderColor = CupertinoColors.systemRed;
        } else if (isFilled || isNext) {
          borderColor = AppColors.getAccentColor(context);
        } else {
          borderColor = isDark
              ? const Color(0xFF38383A)
              : const Color(0xFFE5E5EA);
        }

        final Color bgColor = (isFilled || isNext)
            ? AppColors.getAccentColor(context).withValues(alpha: 0.06)
            : (isDark
                  ? const Color(0xFF1C1C1E).withValues(alpha: 0.5)
                  : const Color(0xFFF2F2F7));

        Widget inner;
        if (isFilled) {
          if (showPin) {
            inner = Text(
              digits[i],
              style: TextStyle(
                fontSize: 22,
                fontWeight: .w700,
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
              ),
            );
          } else {
            inner = Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: mismatch
                    ? CupertinoColors.systemRed
                    : (isDark ? CupertinoColors.white : CupertinoColors.black),
                shape: BoxShape.circle,
              ),
            );
          }
        } else {
          // Blinking cursor indicator on the active next slot
          inner = const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: .circular(12),
            border: .all(
              color: borderColor,
              width: (isFilled || isNext) ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: inner,
        );
      }),
    );
  }
}
