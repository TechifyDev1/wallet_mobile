import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/home/model/recent_transaction_response.dart';
import 'package:wallet/src/features/home/presentation/provider/recent_transaction_provider.dart';
import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../activity/presentation/pages/transaction_detail_page.dart';
import '../../../fund_wallet/presentation/pages/fund_wallet_page.dart';
import 'package:wallet/src/features/send_money/presentation/pages/send_money_page.dart';
import '../../../../common_widgets/shimmer_div.dart';
import '../../../../common_widgets/empty_state.dart';
import '../../../main/presentation/provider/main_nav_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // ─── Responsive helpers ────────────────────────────────────────────────────
  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);
    final txAsync = ref.watch(recentTransactionProvider);
    final userAsync = ref.watch(userProvider);
    final currency = userAsync.asData?.value.wallet.currency ?? 'USD';

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      child: SafeArea(
        child: Column(
          children: [
            // ── Fixed header ──────────────────────────────────────
            _HomeHeader(hPad: hp),
            // ── Scrollable content ────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _HomeBalanceCard(hPad: hp)),
                  SliverToBoxAdapter(child: _HomeQuickActions(hPad: hp)),
                  SliverToBoxAdapter(child: _HomeActivityHeader(hPad: hp)),
                  txAsync.when(
                    data: (transactions) => transactions.isEmpty
                        ? const SliverToBoxAdapter(
                            child: EmptyState(
                              icon: CupertinoIcons.tray,
                              title: 'No Transactions',
                              subtitle:
                                  'When you make transactions, they will appear here.',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _TransactionTile(
                                tx: transactions[index],
                                hPad: hp,
                                currency: currency,
                              ),
                              childCount: transactions.length,
                            ),
                          ),
                    loading: () => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: hp,
                            vertical: 8,
                          ),
                          child: ShimmerDiv(
                            width: double.infinity,
                            height: 60,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        childCount: 4,
                      ),
                    ),
                    error: (err, _) => SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(hp),
                        child: AppText(
                          'Could not load transactions.',
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.iosTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Widgets ─────────────────────────────────────────────────────────

class _HomeHeader extends ConsumerWidget {
  final double hPad;
  const _HomeHeader({required this.hPad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final avatarSize = (MediaQuery.sizeOf(context).width * 0.113).clamp(
      40.0,
      52.0,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.getCardColor(context),
              border: Border.all(
                color: AppColors.getSeparatorColor(context),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Icon(
                CupertinoIcons.person_fill,
                size: avatarSize * 0.62,
                color: AppColors.getAccentColor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting
          Expanded(
            child: userAsync.when(
              data: (summery) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Welcome back,',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.getTextSecondary(context),
                  ),
                  AppText(
                    '${summery.user.firstName} ${summery.user.lastName}',
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.getTextPrimary(context),
                  ),
                ],
              ),
              loading: () => Column(
                crossAxisAlignment: .start,
                children: [
                  ShimmerDiv(
                    width: 100,
                    height: 14,
                    borderRadius: .circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerDiv(
                    width: 150,
                    height: 24,
                    borderRadius: .circular(4),
                  ),
                ],
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          // Notification bell
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.getSeparatorColor(context),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.bell_fill,
                    size: 20,
                    color: AppColors.getAccentColor(context),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.getBackgroundColor(context),
                        width: 1.5,
                      ),
                    ),
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

class _HomeBalanceCard extends ConsumerWidget {
  final double hPad;
  const _HomeBalanceCard({required this.hPad});

  static const Color _primary = Color(0xFF137FEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.051).clamp(16, 24).toDouble();
    final balanceFontSize = (w * 0.087).clamp(28.0, 42.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: CupertinoTheme.brightnessOf(context) == Brightness.dark
              ? AppColors.goldGradient
              : const LinearGradient(
                  colors: [Color(0xFF137FEC), Color(0xFF1A5FCC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: CupertinoTheme.brightnessOf(context) == Brightness.dark
                  ? AppColors.primaryGold.withValues(alpha: 0.35)
                  : _primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: w * 0.33,
                height: w * 0.33,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: w * 0.28,
                height: w * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(hPad),
              child: userAsync.when(
                data: (summery) => Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppText(
                      'Total Balance',
                      variant: AppTextVariant.bodySmall,
                      color:
                          CupertinoTheme.brightnessOf(context) ==
                              Brightness.dark
                          ? const Color(0xFF523B00)
                          : const Color(0xFFBFDBFE),
                    ),
                    SizedBox(height: w * 0.015),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        NumberFormat.simpleCurrency(
                          name: summery.wallet.currency,
                        ).format(summery.wallet.availableBalance.toDouble()),
                        style: TextStyle(
                          color:
                              CupertinoTheme.brightnessOf(context) ==
                                  Brightness.dark
                              ? CupertinoColors.black
                              : CupertinoColors.white,
                          fontSize: balanceFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    SizedBox(height: w * 0.07),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.arrow_up_right,
                                color: Color(0xFF86EFAC),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                '+2.5%',
                                variant: AppTextVariant.bodySmall,
                                color: CupertinoColors.white,
                              ),
                            ],
                          ),
                        ),
                        AppText(
                          '**** ${summery.wallet.walletNumber.substring(summery.wallet.walletNumber.length - 4)}',
                          variant: AppTextVariant.bodySmall,
                          color:
                              CupertinoTheme.brightnessOf(context) ==
                                  Brightness.dark
                              ? const Color(0xFF523B00)
                              : const Color(0xFFBFDBFE),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerDiv(
                      width: 80,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    ShimmerDiv(
                      width: 200,
                      height: balanceFontSize,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerDiv(
                          width: 60,
                          height: 24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        ShimmerDiv(
                          width: 80,
                          height: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
                error: (err, stack) => Center(
                  child: AppText(
                    'Error loading balance',
                    variant: AppTextVariant.bodySmall,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeQuickActions extends ConsumerWidget {
  final double hPad;
  const _HomeQuickActions({required this.hPad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _QuickAction(
        icon: CupertinoIcons.paperplane_fill,
        label: 'Send',
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(builder: (context) => const SendMoneyPage()),
          );
        },
      ),
      _QuickAction(
        icon: CupertinoIcons.plus,
        label: 'Fund',
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(builder: (context) => const FundWalletPage()),
          );
        },
      ),
      _QuickAction(
        icon: CupertinoIcons.clock_fill,
        label: 'History',
        onTap: () {
          ref.read(mainNavProvider.notifier).state = 1;
        },
      ),
      _QuickAction(
        icon: CupertinoIcons.person_fill,
        label: 'Profile',
        onTap: () {
          ref.read(mainNavProvider.notifier).state = 2;
        },
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) => _QuickActionButton(action: a)).toList(),
      ),
    );
  }
}

class _HomeActivityHeader extends ConsumerWidget {
  final double hPad;
  const _HomeActivityHeader({required this.hPad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_alt_fill,
                size: 20,
                color: AppColors.getAccentColor(context),
              ),
              const SizedBox(width: 8),
              AppText(
                'Recent Activity',
                variant: AppTextVariant.bodyLarge,
                color: AppColors.getTextPrimary(context),
              ),
            ],
          ),
          AppButton(
            label: 'See All',
            onPressed: () {
              ref.read(mainNavProvider.notifier).state = 1;
            },
            size: AppButtonSize.small,
            fullWidth: false,
            color: CupertinoColors.transparent,
            textColor: AppColors.getAccentColor(context),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, required this.label, this.onTap});
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final btnSize = (w * 0.149).clamp(52.0, 68.0);
    final iconSize = (w * 0.062).clamp(20.0, 28.0);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final iconColor = AppColors.getAccentColor(context);
    final bgColor = isDark ? AppColors.surfaceDark : const Color(0xFFEFF6FF);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: action.onTap ?? () {},
      child: Column(
        children: [
          Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(action.icon, color: iconColor, size: iconSize),
          ),
          const SizedBox(height: 8),
          AppText(action.label, variant: AppTextVariant.caption),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.tx,
    required this.hPad,
    required this.currency,
  });

  final RecentTransactionResponse tx;
  final double hPad;
  final String currency;

  bool get _isCredit => tx.entryType == EntryType.credit;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final iconSize = (w * 0.113).clamp(40.0, 52.0);
    final iconData = _isCredit
        ? CupertinoIcons.arrow_down
        : CupertinoIcons.arrow_up;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final iconBgColor = _isCredit
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF450A0A) : const Color(0xFFFFECEC));
    final iconColor = _isCredit
        ? (isDark ? AppColors.primaryGold : const Color(0xFF22C55E))
        : const Color(0xFFEF4444);
    final amountStr = _isCredit
        ? '+${NumberFormat.simpleCurrency(name: currency).format(tx.amount.toDouble())}'
        : '-${NumberFormat.simpleCurrency(name: currency).format(tx.amount.toDouble())}';
    final formattedForDetail =
        '${_isCredit ? "+" : "-"}${NumberFormat.simpleCurrency(name: currency).format(tx.amount.toDouble())}';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) => TransactionDetailPage(
              detail: TxDetail(
                amount: formattedForDetail,
                merchant: tx.systemDescription,
                txId: tx.reference,
                dateTime: DateFormat('dd MMM yyyy · hh:mm a').format(tx.time),
                category: _isCredit ? 'Credit' : 'Debit',
                note: tx.note,
                type: tx.entryType,
                status: tx.status,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: iconSize * 0.45),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    tx.systemDescription,
                    variant: AppTextVariant.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  AppText(
                    _formatDate(tx.time),
                    variant: AppTextVariant.caption,
                    color: AppColors.getTextSecondary(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 105, // Fixed width to prevent shifting
              child: AppText(
                amountStr,
                variant: AppTextVariant.bodyMedium,
                color: _isCredit
                    ? (isDark ? AppColors.primaryGold : const Color(0xFF22C55E))
                    : AppColors.getTextPrimary(context),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM, hh:mm a').format(date);
  }
}
