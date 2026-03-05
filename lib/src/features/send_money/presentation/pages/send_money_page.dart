import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/src/common_widgets/shimmer_div.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/send_money/model/recent_contact_response.dart';
import 'package:wallet/src/features/send_money/model/transfer_request.dart';
import 'package:wallet/src/features/send_money/presentation/provider/send_money_provider.dart';
import 'package:wallet/src/features/send_money/presentation/provider/send_money_repository_provider.dart';
import 'package:wallet/src/features/home/presentation/provider/recent_transaction_provider.dart';

import '../../../../common_widgets/app_button.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/storage.dart';
import 'send_success_page.dart';

// ─── Contact Avatar ───────────────────────────────────────────────────────────

class _ContactAvatar extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? initials;
  final String? imageUrl;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const _ContactAvatar({
    required this.label,
    this.icon,
    this.initials,
    this.imageUrl,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, e, st) => _initialsCircle(),
        ),
      );
    } else {
      avatar = _initialsCircle();
    }

    // Add selection border
    if (isSelected) {
      avatar = Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF137FEC), width: 2),
            ),
            child: avatar,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF137FEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark,
                color: CupertinoColors.white,
                size: 10,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          avatar,
          const SizedBox(height: 8),
          AppText(
            label,
            variant: AppTextVariant.caption,
            color: isSelected
                ? const Color(0xFF137FEC)
                : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  Widget _initialsCircle() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: icon != null
            ? Icon(icon, color: iconColor, size: 24)
            : AppText(
                initials!,
                variant: AppTextVariant.bodyMedium,
                color: iconColor,
              ),
      ),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class SendMoneyPage extends ConsumerStatefulWidget {
  const SendMoneyPage({super.key});

  @override
  ConsumerState<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends ConsumerState<SendMoneyPage> {
  static const Color _primary = Color(0xFF137FEC);
  static const Color _slate100 = Color(0xFFF1F5F9);
  static const Color _slate500 = Color(0xFF64748B);

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();

  RecentContactResponse? _selectedReceiver;
  Timer? _debounce;
  bool _showDropdown = false;
  bool _searchLoading = false;
  bool _showPinOverlay = false;
  bool _isSending = false;
  List<RecentContactResponse> _searchResults = [];
  String? _searchError;
  String? _idempotencyKey;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _amountFocusNode.requestFocus();
    });

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // Small delay so tap on dropdown item registers first
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showDropdown = false);
        });
      }
    });
  }

  void _onSearchChanged() {
    final text = _searchController.text;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final query = text.trim();
      if (query.isEmpty) {
        setState(() {
          _showDropdown = false;
          _searchResults = [];
          _searchError = null;
        });
        return;
      }
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _searchLoading = true;
      _showDropdown = true;
      _searchError = null;
    });
    try {
      final results = await ref
          .read(sendMoneyRepositoryProvider)
          .searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _searchLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = 'Could not search users';
          _searchLoading = false;
        });
      }
    }
  }

  void _selectReceiver(RecentContactResponse user) {
    setState(() {
      _selectedReceiver = user;
      _showDropdown = false;
      _searchResults = [];
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _clearReceiver() {
    setState(() => _selectedReceiver = null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _searchController.dispose();
    _noteController.dispose();
    _pinController.dispose();
    _amountFocusNode.dispose();
    _searchFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Widget _buildStackWrap(Widget child) {
    final w = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        child,
        if (_showPinOverlay) _buildPinOverlay(w),
        if (_isSending)
          Container(
            color: CupertinoColors.black.withValues(alpha: 0.3),
            child: const Center(child: CupertinoActivityIndicator()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);
    final sendAsync = ref.watch(sendMoneyProvider);
    final userAsync = ref.watch(userProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      child: _buildStackWrap(
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _buildHeader(context, hp),

              // ── Search Bar or Selected Receiver ─────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hp, vertical: 12),
                child: _selectedReceiver == null
                    ? _buildSearchArea()
                    : _buildReceiverCard(_selectedReceiver!),
              ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ── Recent Contacts (Now above amount) ──────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: _buildRecentContacts(hp, sendAsync),
                      ),
                    ),

                    // ── Main Content (Amount) ──────────────────────────
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAmountInput(
                              w,
                              userAsync.asData?.value.wallet.currency ?? 'USD',
                            ),
                            _buildNoteInput(),
                            const SizedBox(height: 24),
                            userAsync.when(
                              data: (summary) => AppText(
                                'Available balance: ${NumberFormat.simpleCurrency(name: summary.wallet.currency).format(summary.wallet.availableBalance.toDouble())}',
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.getTextSecondary(context),
                              ),
                              loading: () => ShimmerDiv(width: 140, height: 16),
                              error: (_, _) => AppText(
                                'Available balance: --',
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.getTextSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom Actions (Fixed at bottom) ─────────────────────
              _buildBottomArea(context, hp),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Selected Receiver Card ────────────────────────────────────────────────
  Widget _buildReceiverCard(RecentContactResponse receiver) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildMiniAvatar(receiver),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '@${receiver.userName}',
                  variant: AppTextVariant.bodyLarge,
                  color: _primary,
                  fontWeight: FontWeight.w700,
                ),
                AppText(
                  'Selected Recipient',
                  variant: AppTextVariant.caption,
                  color: _primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _clearReceiver,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'Change',
                  variant: AppTextVariant.bodySmall,
                  color: _primary,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  color: _primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(RecentContactResponse receiver) {
    if (receiver.profilePicUrl != null && receiver.profilePicUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          receiver.profilePicUrl!,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (_, e, st) => _miniInitialsCircle(receiver.userName),
        ),
      );
    }
    return _miniInitialsCircle(receiver.userName);
  }

  Widget _miniInitialsCircle(String userName) {
    final initials = userName.length >= 2
        ? userName.substring(0, 2).toUpperCase()
        : userName.toUpperCase();
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFFFDE68A),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF92400E),
          ),
        ),
      ),
    );
  }

  // ─── Search Area with Dropdown ─────────────────────────────────────────────
  Widget _buildSearchArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CupertinoTextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(
                CupertinoIcons.search,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
            suffix: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _showDropdown = false;
                        _searchResults = [];
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                  )
                : null,
            placeholder: 'Search by username, email or phone',
            placeholderStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFF94A3B8),
            ),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.getTextPrimary(context),
            ),
            decoration: null,
          ),
        ),

        // Dropdown
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildDropdownContent(),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownContent() {
    if (_searchLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (_searchError != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: AppText(
          _searchError!,
          variant: AppTextVariant.bodyMedium,
          color: const Color(0xFF94A3B8),
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.person_crop_circle,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 10),
            AppText(
              'No users found',
              variant: AppTextVariant.bodyMedium,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      separatorBuilder: (_, i) =>
          Container(height: 1, color: AppColors.getSeparatorColor(context)),
      itemBuilder: (context, i) => _buildDropdownItem(_searchResults[i]),
    );
  }

  Widget _buildDropdownItem(RecentContactResponse user) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _selectReceiver(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildDropdownAvatar(user),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                '@${user.userName}',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Color(0xFFCBD5E1),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownAvatar(RecentContactResponse user) {
    if (user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          user.profilePicUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, e, st) => _dropdownInitialsCircle(user.userName),
        ),
      );
    }
    return _dropdownInitialsCircle(user.userName);
  }

  Widget _dropdownInitialsCircle(String userName) {
    final initials = userName.length >= 2
        ? userName.substring(0, 2).toUpperCase()
        : userName.toUpperCase();
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFFDE68A),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF92400E),
          ),
        ),
      ),
    );
  }

  // ─── Amount Input ──────────────────────────────────────────────────────────
  Widget _buildNoteInput() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoTextField(
        controller: _noteController,
        placeholder: 'Add a note (optional)',
        placeholderStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 15,
        ),
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 15,
        ),
        decoration: null,
        maxLines: 1,
      ),
    );
  }

  Widget _buildAmountInput(double w, String currency) {
    final fontSize = (w * 0.16).clamp(56.0, 84.0);
    final dollarSize = (w * 0.08).clamp(28.0, 48.0);
    final symbol = NumberFormat.simpleCurrency(name: currency).currencySymbol;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: dollarSize,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
        IntrinsicWidth(
          child: CupertinoTextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            placeholder: '0',
            placeholderStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE2E8F0),
            ),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -2,
            ),
            decoration: null,
            cursorColor: _primary,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Bottom Actions ────────────────────────────────────────────────────────
  Widget _buildBottomArea(BuildContext context, double hp) {
    final hasReceiver = _selectedReceiver != null;
    return Container(
      color: AppColors.getCardColor(context),
      padding: EdgeInsets.fromLTRB(
        hp,
        0,
        hp,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          label: 'Next',
          onPressed: hasReceiver
              ? () {
                  setState(() {
                    _showPinOverlay = true;
                    _pinController.clear();
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _pinFocusNode.requestFocus();
                  });
                }
              : null,
          size: AppButtonSize.large,
        ),
      ),
    );
  }

  Widget _buildPinOverlay(double w) {
    return Container(
      color: CupertinoColors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          width: w * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Enter PIN', variant: AppTextVariant.bodyLarge),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(() => _showPinOverlay = false),
                    child: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AppText(
                'Please enter your 6-digit transaction PIN to authorize this transfer.',
                variant: AppTextVariant.bodySmall,
                color: Color(0xFF64748B),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  final isFilled = _pinController.text.length > index;
                  return Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? _primary : const Color(0xFFE2E8F0),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              // Hidden TextField
              SizedBox(
                height: 0,
                width: 0,
                child: CupertinoTextField(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (val) {
                    if (val.length == 6) {
                      _completeTransfer();
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeTransfer() async {
    setState(() {
      _showPinOverlay = false;
      _isSending = true;
    });

    try {
      // Logic from user: idempotency key management
      _idempotencyKey ??= const Uuid().v4();
      await Storage.write("idempotencyKey", _idempotencyKey!);

      final amount = _amountController.text;
      await ref
          .read(sendMoneyProvider.notifier)
          .sendMoney(
            TransferRequest(
              amount: Decimal.parse(amount.isEmpty ? '0.00' : amount),
              receiverUsername: _selectedReceiver!.userName,
              idempotencyKey: _idempotencyKey!,
              comment: _noteController.text,
              transactionPin: _pinController.text,
            ),
          );

      // Refresh data
      unawaited(ref.read(recentTransactionProvider.notifier).refresh());
      unawaited(ref.read(userProvider.notifier).refresh());

      // Success: clean up key
      await Storage.delete("idempotencyKey");
      _idempotencyKey = null;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
            builder: (ctx) => SendSuccessPage(
              amount: amount.isEmpty ? '0.00' : amount,
              recipient: '@${_selectedReceiver!.userName}',
              currency:
                  ref.read(userProvider).asData?.value.wallet.currency ?? 'USD',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Transfer Failed'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double hp) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hp - 4, vertical: 10),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.back, color: _primary, size: 22),
                AppText(
                  'Back',
                  variant: AppTextVariant.bodyLarge,
                  color: _primary,
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: AppText('Send Money', variant: AppTextVariant.bodyLarge),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  // ─── Recent Contacts ────────────────────────────────────────────────────────
  Widget _buildRecentContacts(
    double hp,
    AsyncValue<List<RecentContactResponse>> sendAsync,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ContactAvatar(
              label: 'New',
              icon: CupertinoIcons.person_badge_plus,
              bgColor: _slate100,
              iconColor: _slate500,
            ),
            const SizedBox(width: 20),

            ...sendAsync.when(
              data: (data) => data
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _ContactAvatar(
                        initials: r.userName.length >= 2
                            ? r.userName.substring(0, 2).toUpperCase()
                            : r.userName.toUpperCase(),
                        label: r.userName,
                        imageUrl: r.profilePicUrl,
                        bgColor: const Color(0xFFFDE68A),
                        iconColor: const Color(0xFF92400E),
                        onTap: () => _selectReceiver(r),
                        isSelected: _selectedReceiver?.userName == r.userName,
                      ),
                    ),
                  )
                  .toList(),
              error: (e, st) {
                debugPrint(e.toString());
                return [const SizedBox()];
              },
              loading: () => [ShimmerDiv(width: 56, height: 56)],
            ),
          ],
        ),
      ),
    );
  }

  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();
}
