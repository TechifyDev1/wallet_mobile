import 'package:flutter/cupertino.dart';
import 'package:wallet/src/features/home/model/recent_transaction_response.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Model passed in from the list ────────────────────────────────────────────

class TxDetail {
  final String amount;
  final String merchant;
  final String txId;
  final String dateTime;
  final String category;
  final String note;
  final EntryType type;
  final TransactionStatus status;

  const TxDetail({
    required this.amount,
    required this.merchant,
    required this.txId,
    required this.dateTime,
    required this.category,
    required this.note,
    required this.type,
    required this.status,
  });

  bool get isCredit => type == EntryType.credit;

  Color getIconBgColor(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    if (isCredit) {
      return isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
    }
    return isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
  }

  Color getIconColor(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    if (isCredit) {
      return isDark ? AppColors.primaryGold : const Color(0xFF16A34A);
    }
    return const Color(0xFFDC2626);
  }

  IconData get icon => isCredit
      ? CupertinoIcons.arrow_down_left_circle_fill
      : CupertinoIcons.arrow_up_right_circle_fill;

  Color getAmountColor(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    if (isCredit) {
      return isDark ? AppColors.primaryGold : const Color(0xFF16A34A);
    }
    return AppColors.getTextPrimary(context);
  }

  Color getStatusBgColor(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    switch (status) {
      case TransactionStatus.completed:
      case TransactionStatus.success:
        return isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
      case TransactionStatus.pending:
        return isDark ? const Color(0xFF422006) : const Color(0xFFFEF9C3);
      case TransactionStatus.failed:
        return isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
    }
  }

  Color getStatusTextColor(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    switch (status) {
      case TransactionStatus.completed:
      case TransactionStatus.success:
        return isDark ? AppColors.primaryGold : const Color(0xFF15803D);
      case TransactionStatus.pending:
        return isDark ? const Color(0xFFFACC15) : const Color(0xFFCA8A04);
      case TransactionStatus.failed:
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFB91C1C);
    }
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.detail});
  final TxDetail detail;

  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Sticky header ──────────────────────────────────────
            _buildHeader(context, hp),
            // ── Scrollable body ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: .fromLTRB(hp, 32, hp, 48),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    _buildHero(context, w),
                    const SizedBox(height: 32),
                    _buildInfoSection(context),
                    const SizedBox(height: 32),
                    _buildActions(context),
                    const SizedBox(height: 24),
                    _buildFootnote(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double hp) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(context).withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: hp - 4, vertical: 10),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.back,
                  color: AppColors.getAccentColor(context),
                  size: 22,
                ),
                AppText(
                  'Wallet',
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.getAccentColor(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AppText(
                'Transaction Details',
                variant: AppTextVariant.bodyLarge,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ),
          // Spacer to balance left button width
          const SizedBox(width: 72),
        ],
      ),
    );
  }

  // ─── Hero (icon + amount + status) ────────────────────────────────────────
  Widget _buildHero(BuildContext context, double w) {
    final iconContainerSize = (w * 0.164).clamp(60.0, 72.0);
    final amountSize = (w * 0.103).clamp(36.0, 46.0);

    return Column(
      children: [
        // Icon
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: detail.getIconBgColor(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            detail.icon,
            color: detail.getIconColor(context),
            size: iconContainerSize * 0.46,
          ),
        ),
        SizedBox(height: w * 0.05),
        // Amount
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            detail.amount,
            style: TextStyle(
              fontSize: amountSize,
              fontWeight: FontWeight.w700,
              color: detail.getAmountColor(context),
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: detail.getStatusBgColor(context),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: detail.getStatusTextColor(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: detail.getStatusTextColor(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              AppText(
                detail.status.name[0].toUpperCase() +
                    detail.status.name.substring(1),
                variant: AppTextVariant.caption,
                color: detail.getStatusTextColor(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Info section ──────────────────────────────────────────────────────────
  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: AppText(
            'INFORMATION',
            variant: AppTextVariant.caption,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.getSeparatorColor(context),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // To / From
              _InfoRow(
                label: detail.isCredit ? 'From' : 'To',
                divider: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        detail.merchant,
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.getTextPrimary(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: detail.getIconBgColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        detail.isCredit
                            ? CupertinoIcons.arrow_down_left
                            : CupertinoIcons.arrow_up_right,
                        size: 15,
                        color: detail.getIconColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Transaction ID
              _InfoRow(
                label: 'Transaction ID',
                divider: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail.txId,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Courier',
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () {},
                      child: Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 18,
                        color: AppColors.getAccentColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Date & Time
              _InfoRow(
                label: 'Date & Time',
                divider: true,
                child: AppText(
                  detail.dateTime,
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              // Category
              _InfoRow(
                label: 'Category',
                divider: detail.note.isNotEmpty,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: detail
                            .getIconBgColor(context)
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        detail.category.toUpperCase(),
                        variant: AppTextVariant.caption,
                        color: detail.getIconColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Note (Optional)
              if (detail.note.isNotEmpty)
                _InfoRow(
                  label: 'Note',
                  divider: false,
                  child: AppText(
                    detail.note,
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.getTextPrimary(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // Download Receipt — primary filled
        AppButton(
          label: 'Download Receipt',
          onPressed: () {},
          icon: CupertinoIcons.doc_text_fill,
          size: AppButtonSize.large,
        ),
        const SizedBox(height: 10),
        // Report a Problem — outlined
        AppButton(
          label: 'Report a Problem',
          onPressed: () {},
          size: AppButtonSize.large,
          outlined: true,
          color: AppColors.getTextPrimary(context),
        ),
      ],
    );
  }

  // ─── Footnote ──────────────────────────────────────────────────────────────
  Widget _buildFootnote(BuildContext context) {
    return AppText(
      'This transaction was processed via your primary debit account ending in ••82.',
      variant: AppTextVariant.caption,
      color: AppColors.getTextSecondary(context),
      textAlign: TextAlign.center,
    );
  }
}

// ─── Info row helper ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.child,
    required this.divider,
  });

  final String label;
  final Widget child;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: divider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.getSeparatorColor(context),
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: AppTextVariant.caption,
            color: AppColors.getTextSecondary(context),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
