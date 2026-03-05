import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';

class SendSuccessPage extends StatelessWidget {
  const SendSuccessPage({
    super.key,
    required this.amount,
    required this.recipient,
    required this.currency,
  });

  final String amount;
  final String recipient;
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
        top: false,
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
                      'Money Sent Successfully',
                      variant: AppTextVariant.displaySmall,
                      color: AppColors.getTextPrimary(context),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Your transfer is on its way',
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.iosTextSecondary,
                    ),
                    const SizedBox(height: 48),

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
                          // Amount
                          Text(
                            NumberFormat.simpleCurrency(
                              name: currency,
                            ).format(double.tryParse(amount) ?? 0.0),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppColors.getTextPrimary(context),
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                'to ',
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.iosTextSecondary,
                              ),
                              AppText(
                                recipient,
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: AppColors.getSeparatorColor(context),
                          ),
                          const SizedBox(height: 24),

                          // Info Rows
                          _InfoRow(
                            label: 'Transaction ID',
                            value: '#TXN-8829-4410',
                            valueFontFamily: 'Courier',
                          ),
                          const SizedBox(height: 16),
                          const _InfoRow(
                            label: 'Date',
                            value: 'Oct 24, 2023 • 10:45 AM',
                          ),
                          const SizedBox(height: 16),
                          const _InfoRow(
                            label: 'Payment Method',
                            value: 'Wallet Balance',
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Bottom Actions ────────────────────────────────────────
                    AppButton(
                      label: 'Back to Dashboard',
                      onPressed: () {
                        // Pop back to Home
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      size: AppButtonSize.large,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.share,
                              color: CupertinoColors.activeBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              'Share Receipt',
                              variant: AppTextVariant.bodyMedium,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ],
                        ),
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

// ─── Info Row Helper ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueFontFamily,
  });

  final String label;
  final String value;
  final String? valueFontFamily;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: AppColors.iosTextSecondary,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextPrimary(context),
            fontFamily: valueFontFamily,
          ),
        ),
      ],
    );
  }
}
