import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/src/core/theme/theme_provider.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/auth/presentation/pages/register_page.dart';
import 'package:wallet/src/common_widgets/shimmer_div.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_profile_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notifications = true;
  double _hPad(double w) => (w * 0.051).clamp(16, 28).toDouble();

  @override
  Widget build(BuildContext context) {
    final brightness = ref.watch(themeProvider);
    final isDark = brightness == Brightness.dark;
    final w = MediaQuery.sizeOf(context).width;
    final hp = _hPad(w);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: const AppText('Settings', variant: AppTextVariant.bodyLarge),
        backgroundColor: AppColors.getCardColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            _SettingsProfileSection(hPad: hp),
            const SizedBox(height: 24),
            _buildSectionLabel('Preferences', hp),
            _buildGroupedList(hp, [
              _buildToggleRow(
                icon: CupertinoIcons.bell_fill,
                iconColor: const Color(0xFFEF4444),
                label: 'Notifications',
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              // _buildToggleRow(
              //   icon: CupertinoIcons.lock_fill,
              //   iconColor: AppColors.getAccentColor(context),
              //   label: 'Biometric Login',
              //   value: _biometrics,
              //   onChanged: (v) => setState(() => _biometrics = v),
              // ),
              _buildToggleRow(
                icon: CupertinoIcons.moon_fill,
                iconColor: const Color(0xFF8B5CF6),
                label: 'Dark Mode',
                value: isDark,
                onChanged: (v) =>
                    ref.read(themeProvider.notifier).toggleTheme(),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionLabel('Account', hp),
            _buildGroupedList(hp, [
              _buildNavRow(
                icon: CupertinoIcons.person_fill,
                iconColor: AppColors.getAccentColor(context),
                label: 'Edit Profile',
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
              ),
              _buildNavRow(
                icon: CupertinoIcons.shield_lefthalf_fill,
                iconColor: const Color(0xFF22C55E),
                label: 'Privacy & Security',
                onTap: () {},
              ),
              _buildNavRow(
                icon: CupertinoIcons.chat_bubble_2_fill,
                iconColor: const Color(0xFFF59E0B),
                label: 'Contact Support',
                onTap: () async {
                  final url = Uri.parse('https://wa.me/2349045892076');
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        showCupertinoDialog(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: const Text('Support Unavailable'),
                            content: const Text(
                              'Could not open the support link. Please make sure you have WhatsApp installed or contact us at support@walletapp.com',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error launching support: $e');
                  }
                },
              ),
            ]),
            const SizedBox(height: 24),
            // Sign out button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hp),
              child: CupertinoButton(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(14),
                onPressed: _showLogoutDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.arrow_right_square_fill,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      'Sign Out',
                      variant: AppTextVariant.bodyMedium,
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out from your account?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(userProvider.notifier).logout();
              // Navigate to root to ensure clean logout
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (_) => const RegisterPage()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // ─── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label, double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 8),
      child: AppText(
        label.toUpperCase(),
        variant: AppTextVariant.caption,
        color: AppColors.getTextSecondary(context),
      ),
    );
  }

  // ─── Grouped list container ────────────────────────────────────────────────
  Widget _buildGroupedList(double hp, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hp),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children
            .expand(
              (w) => [
                w,
                if (w != children.last)
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: SizedBox(
                      height: 0.5,
                      child: ColoredBox(
                        color: AppColors.getSeparatorColor(context),
                      ),
                    ),
                  ),
              ],
            )
            .toList(),
      ),
    );
  }

  // ─── Toggle row ────────────────────────────────────────────────────────────
  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.getAccentColor(context),
          ),
        ],
      ),
    );
  }

  // ─── Nav row ───────────────────────────────────────────────────────────────
  Widget _buildNavRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AppText(
                label,
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Color(0xFFC7C7CC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Widgets ─────────────────────────────────────────────────────────

class _SettingsProfileSection extends ConsumerWidget {
  final double hPad;
  const _SettingsProfileSection({required this.hPad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final w = MediaQuery.sizeOf(context).width;
    final avatarSize = (w * 0.144).clamp(50.0, 64.0);

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final accentColor = AppColors.getAccentColor(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(CupertinoPageRoute(builder: (_) => const EditProfilePage()));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.surfaceDark : const Color(0xFFEFF6FF),
                border: Border.all(
                  color: isDark ? accentColor : const Color(0xFFBFDBFE),
                  width: 2,
                ),
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: avatarSize * 0.52,
                color: isDark ? accentColor : AppColors.getAccentColor(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: userAsync.when(
                data: (summery) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${summery.user.firstName} ${summery.user.lastName}',
                      variant: AppTextVariant.bodyLarge,
                      color: AppColors.getTextPrimary(context),
                    ),
                    AppText(
                      summery.user.email,
                      variant: AppTextVariant.caption,
                      color: AppColors.iosTextSecondary,
                    ),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerDiv(
                      width: 120,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    ShimmerDiv(
                      width: 180,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                error: (_, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Error loading info',
                      variant: AppTextVariant.bodyLarge,
                      color: AppColors.getTextPrimary(context),
                    ),
                    AppText(
                      'Unable to fetch details',
                      variant: AppTextVariant.caption,
                      color: AppColors.iosTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Color(0xFFC7C7CC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
