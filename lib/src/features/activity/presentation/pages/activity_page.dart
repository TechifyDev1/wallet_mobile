import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/home/model/recent_transaction_response.dart';
import 'package:wallet/src/features/home/presentation/provider/recent_transaction_provider.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../common_widgets/shimmer_div.dart';
import '../../../../common_widgets/empty_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../send_money/presentation/pages/send_money_page.dart';
import 'transaction_detail_page.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(recentTransactionProvider.notifier).loadMore();
    }
  }

  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);
    final txAsync = ref.watch(recentTransactionProvider);
    final isFetchingMore = ref
        .watch(recentTransactionProvider.notifier)
        .isFetchingMore;
    final hasMore = ref.watch(recentTransactionProvider.notifier).hasMore;
    final currency =
        ref.watch(userProvider).asData?.value.wallet.currency ?? 'USD';

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            txAsync.when(
              data: (transactions) {
                final sorted = [...transactions]
                  ..sort((a, b) => b.time.compareTo(a.time));
                final grouped = _groupByDate(sorted);
                final entries = grouped.entries.toList();

                return transactions.isEmpty
                    ? Center(
                        child: EmptyState(
                          icon: CupertinoIcons.tray_full,
                          title: 'Nothing Here Yet',
                          subtitle:
                              'You haven\'t made any transactions. Why not send some money to a friend?',
                          actionLabel: 'Send Money',
                          onAction: () {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (context) => const SendMoneyPage(),
                              ),
                            );
                          },
                        ),
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () => ref
                                .read(recentTransactionProvider.notifier)
                                .refresh(),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 56)),
                          for (int gi = 0; gi < entries.length; gi++) ...[
                            SliverToBoxAdapter(
                              child: _GroupHeader(
                                label: entries[gi].key,
                                hPad: hp,
                                topBorder: gi > 0,
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _RecentTxTile(
                                  tx: entries[gi].value[i],
                                  hPad: hp,
                                  currency: currency,
                                ),
                                childCount: entries[gi].value.length,
                              ),
                            ),
                          ],
                          if (hasMore)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Center(
                                  child: isFetchingMore
                                      ? const CupertinoActivityIndicator()
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 48)),
                        ],
                      );
              },
              loading: () => CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 56)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: hp,
                          vertical: 8,
                        ),
                        child: ShimmerDiv(
                          width: double.infinity,
                          height: 64,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      childCount: 6,
                    ),
                  ),
                ],
              ),
              error: (err, _) => Center(
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
            _StickyHeader(hp: hp),
          ],
        ),
      ),
    );
  }

  // ─── Grouping Logic ─────────────────────────────────────────────

  Map<String, List<RecentTransactionResponse>> _groupByDate(
    List<RecentTransactionResponse> list,
  ) {
    final Map<String, List<RecentTransactionResponse>> grouped = {};

    for (final tx in list) {
      final label = _dateLabel(tx.time);

      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(tx);
    }

    return grouped;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) return 'Today';
    if (txDate == yesterday) return 'Yesterday';

    return '${_monthName(date.month)} ${date.day}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}

class _StickyHeader extends StatelessWidget {
  const _StickyHeader({required this.hp});
  final double hp;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(context).withValues(alpha: 0.92),
          border: Border(
            bottom: BorderSide(
              color: AppColors.getSeparatorColor(context),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hp - 4),
          child: Row(
            children: [
              const SizedBox(width: 26), // balance the search icon
              Expanded(
                child: Center(
                  child: AppText(
                    'Transaction History',
                    variant: AppTextVariant.bodyLarge,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {},
                child: Icon(
                  CupertinoIcons.search,
                  size: 22,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.hPad,
    required this.topBorder,
  });

  final String label;
  final double hPad;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: topBorder ? const EdgeInsets.only(top: 8) : EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 4),
      child: AppText(
        label.toUpperCase(),
        variant: AppTextVariant.caption,
        color: AppColors.getTextSecondary(context),
      ),
    );
  }
}

class _RecentTxTile extends StatelessWidget {
  final RecentTransactionResponse tx;
  final double hPad;
  final String currency;

  const _RecentTxTile({
    required this.tx,
    required this.hPad,
    required this.currency,
  });

  bool get isCredit => tx.entryType == EntryType.credit;

  Color getAmountColor(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    if (isCredit) {
      return isDark ? AppColors.primaryGold : const Color(0xFF16A34A);
    }
    return AppColors.getTextPrimary(context);
  }

  Color getIconBg(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final iconSize = (w * 0.123).clamp(44.0, 56.0);

    final time =
        '${tx.time.hour.toString().padLeft(2, '0')}:${tx.time.minute.toString().padLeft(2, '0')}';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (_) => TransactionDetailPage(
              detail: TxDetail(
                amount:
                    '${isCredit ? '+' : '-'}${NumberFormat.simpleCurrency(name: currency).format(tx.amount.toDouble())}',
                merchant: tx.systemDescription,
                txId: tx.reference,
                dateTime: DateFormat('dd MMM yyyy · hh:mm a').format(tx.time),
                category: isCredit ? 'Credit' : 'Debit',
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
                color: getIconBg(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit
                    ? CupertinoIcons.arrow_down_left
                    : CupertinoIcons.arrow_up_right,
                color: getIconColor(context),
                size: iconSize * 0.46,
              ),
            ),
            SizedBox(width: hPad * 0.85),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    tx.systemDescription,
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.getTextPrimary(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  AppText(
                    tx.note.isEmpty ? time : '${tx.note} • $time',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.getTextSecondary(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 105, // Fixed width to prevent shifting
              child: AppText(
                '${isCredit ? '+' : '-'}${NumberFormat.simpleCurrency(name: currency).format(tx.amount.toDouble())}',
                variant: AppTextVariant.bodyMedium,
                color: getAmountColor(context),
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
}
