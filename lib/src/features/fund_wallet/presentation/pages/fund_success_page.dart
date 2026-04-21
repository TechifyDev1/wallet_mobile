import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';

class FundSuccessPage extends StatelessWidget {
  const FundSuccessPage({
    super.key,
    required this.amount,
    required this.currency,
  });

  final String amount;
  final String currency;

  static const Color _success = Color(0xFF34C759);

  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);
    final topPadding = MediaQuery.paddingOf(context).top;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      child: SafeArea(
        top:
            false, // We'll handle top padding manually for the checkmark spacing
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: topPadding + 60),

                    // ── Success Icon ──────────────────────────────────────────
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.check_mark,
                        color: _success,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Header Text ───────────────────────────────────────────
                    AppText(
                      'Funding Successful',
                      variant: AppTextVariant.displaySmall,
                      color: AppColors.getTextPrimary(context),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Your wallet has been topped up successfully.',
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.iosTextSecondary,
                    ),
                    const SizedBox(height: 48),

                    // ── Amount ────────────────────────────────────────────────
                    Text(
                      '+${NumberFormat.simpleCurrency(name: currency).format(double.tryParse(amount) ?? 0.0)}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Details Card ──────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.getSeparatorColor(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // New Balance Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                'New Balance',
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.iosTextSecondary,
                              ),
                              AppText(
                                NumberFormat.simpleCurrency(
                                  name: currency,
                                ).format(2840.50),
                                variant: AppTextVariant.bodyLarge,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: AppColors.getSeparatorColor(context),
                          ),
                          const SizedBox(height: 16),

                          // Payment Method Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                'Payment\nMethod',
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.iosTextSecondary,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.creditcard,
                                    size: 16,
                                    color: Color(0xFF94A3B8), // slate-400
                                  ),
                                  const SizedBox(width: 8),
                                  AppText(
                                    'Bank Account •••• 8291',
                                    variant: AppTextVariant.bodySmall,
                                    color: AppColors.getTextPrimary(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Bottom Actions ────────────────────────────────────────
                    AppButton(
                      label: 'Done',
                      onPressed: () {
                        // Pop back to MainTabs (go back 2 routes: FundSuccessPage -> FundWalletPage -> MainTabs)
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      size: AppButtonSize.large,
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: AppText(
                        'View Transaction Details',
                        variant: AppTextVariant.bodySmall,
                        color: const Color(0xFF94A3B8), // slate-400
                      ),
                    ),
                    const SizedBox(height: 16),
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
