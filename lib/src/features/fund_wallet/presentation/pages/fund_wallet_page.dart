import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../common_widgets/shimmer_div.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/user/presentation/provider/user_provider.dart';
import '../providers/fund_wallet_provider.dart';
import 'package:wallet/src/features/home/presentation/provider/recent_transaction_provider.dart';
import 'fund_success_page.dart';

class FundWalletPage extends ConsumerStatefulWidget {
  const FundWalletPage({super.key});

  @override
  ConsumerState<FundWalletPage> createState() => _FundWalletPageState();
}

class _FundWalletPageState extends ConsumerState<FundWalletPage> {
  static const Color _primary = Color(0xFF137FEC);

  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the input on screen load
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _setAmount(String amount) {
    _amountController.text = amount;
    // Move cursor to end
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);
    final userAsync = ref.watch(userProvider);

    ref.listen(fundWalletNotifierProvider, (previous, next) {
      next.when(
        data: (response) {
          if (response != null) {
            unawaited(
              ref.read(recentTransactionProvider.notifier).refresh().onError((
                error,
                stackTrace,
              ) {
                return null;
              }),
            );

            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => FundSuccessPage(
                  amount: _amountController.text.isEmpty
                      ? '0.00'
                      : _amountController.text,
                  currency: userAsync.asData?.value.wallet.currency ?? 'USD',
                ),
              ),
            );
          }
        },
        loading: () {},
        error: (error, st) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Funding Failed'),
              content: Text(error.toString()),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            const _FundHeader(),

            // ── Main Content ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'ENTER AMOUNT',
                      variant: AppTextVariant.caption,
                      color: AppColors.iosTextSecondary,
                    ),
                    const SizedBox(height: 16),
                    userAsync.when(
                      data: (summary) =>
                          _buildAmountInput(w, summary.wallet.currency),
                      loading: () => _buildAmountInput(w, 'USD'),
                      error: (_, _) => _buildAmountInput(w, 'USD'),
                    ),
                    const SizedBox(height: 24),
                    const _FundCurrencyBadge(),
                  ],
                ),
              ),
            ),

            // ── Bottom Actions ──────────────────────────────────────
            _FundBottomArea(
              hPad: hp,
              amountController: _amountController,
              onSetAmount: _setAmount,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Amount Input ──────────────────────────────────────────────────────────
  Widget _buildAmountInput(double w, String currency) {
    final fontSize = (w * 0.15).clamp(48.0, 72.0);
    final dollarSize = (w * 0.08).clamp(24.0, 48.0);
    final symbol = NumberFormat.simpleCurrency(name: currency).currencySymbol;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: dollarSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8), // slate-400
            ),
          ),
        ),
        IntrinsicWidth(
          child: CupertinoTextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            placeholder: '0.00',
            placeholderStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE2E8F0), // slate-200
            ),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -1,
            ),
            decoration: null, // Removes default border
            cursorColor: _primary,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section Widgets ─────────────────────────────────────────────────────────

class _FundHeader extends StatelessWidget {
  const _FundHeader();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = (w * 0.051).clamp(16.0, 28.0).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hp - 4, vertical: 10),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(
              CupertinoIcons.back,
              color: CupertinoColors.activeBlue,
              size: 26,
            ),
          ),
          const Expanded(
            child: Center(
              child: AppText('Fund Wallet', variant: AppTextVariant.bodyLarge),
            ),
          ),
          const SizedBox(width: 26),
        ],
      ),
    );
  }
}

class _FundCurrencyBadge extends ConsumerWidget {
  const _FundCurrencyBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    const primary = Color(0xFF137FEC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.getSeparatorColor(context),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: const Icon(CupertinoIcons.globe, size: 12, color: primary),
          ),
          const SizedBox(width: 8),
          userAsync.when(
            data: (summary) => AppText(
              summary.wallet.currency,
              variant: AppTextVariant.bodySmall,
              color: const Color(0xFF334155),
            ),
            loading: () => ShimmerDiv(width: 30, height: 12),
            error: (_, _) => AppText(
              'USD',
              variant: AppTextVariant.bodySmall,
              color: const Color(0xFF334155),
            ),
          ),
          Container(
            width: 1,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFCBD5E1),
          ),
          userAsync.when(
            data: (summery) => AppText(
              'Balance: ${NumberFormat.simpleCurrency(name: summery.wallet.currency).format(summery.wallet.availableBalance.toDouble())}',
              variant: AppTextVariant.caption,
              color: AppColors.iosTextSecondary,
            ),
            loading: () => ShimmerDiv(
              width: 80,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
            error: (_, _) => AppText(
              'Balance: --',
              variant: AppTextVariant.caption,
              color: AppColors.iosTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FundBottomArea extends ConsumerWidget {
  final double hPad;
  final TextEditingController amountController;
  final void Function(String) onSetAmount;

  const _FundBottomArea({
    required this.hPad,
    required this.amountController,
    required this.onSetAmount,
  });

  static const Color _primary = Color(0xFF137FEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundAsync = ref.watch(fundWalletNotifierProvider);
    final isLoading = fundAsync.isLoading;

    return Container(
      color: AppColors.getCardColor(context),
      padding: EdgeInsets.fromLTRB(
        hPad,
        16,
        hPad,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        children: [
          ref
              .watch(userProvider)
              .when(
                data: (summary) {
                  final currency = summary.wallet.currency;
                  final symbol = NumberFormat.simpleCurrency(
                    name: currency,
                  ).currencySymbol;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PresetButton(
                        label: '$symbol 50',
                        onTap: () => onSetAmount('50'),
                      ),
                      const SizedBox(width: 12),
                      _PresetButton(
                        label: '$symbol 100',
                        onTap: () => onSetAmount('100'),
                      ),
                      const SizedBox(width: 12),
                      _PresetButton(
                        label: '$symbol 200',
                        onTap: () => onSetAmount('200'),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PresetButton(
                      label: '\$ 50',
                      onTap: () => onSetAmount('50'),
                    ),
                    const SizedBox(width: 12),
                    _PresetButton(
                      label: '\$ 100',
                      onTap: () => onSetAmount('100'),
                    ),
                    const SizedBox(width: 12),
                    _PresetButton(
                      label: '\$ 200',
                      onTap: () => onSetAmount('200'),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 24),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: amountController,
            builder: (context, value, _) {
              final amountStr = value.text;
              final amount = Decimal.tryParse(amountStr);
              final isValid = amount != null && amount > Decimal.zero;

              return SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: _primary,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: (isLoading || !isValid)
                      ? null
                      : () {
                          ref
                              .read(fundWalletNotifierProvider.notifier)
                              .fundWallet(amount);
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading)
                        const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      else ...[
                        const AppText(
                          'Proceed to Pay',
                          variant: AppTextVariant.bodyMedium,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_right,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: AppColors.getSeparatorColor(context),
            width: 1,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}
