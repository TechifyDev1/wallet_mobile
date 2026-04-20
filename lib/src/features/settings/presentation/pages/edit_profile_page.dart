import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';
import 'package:wallet/src/features/auth/presentation/pages/register_page.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_name_page.dart';
import 'edit_email_page.dart';
import 'edit_phone_page.dart';
import 'reset_password_page.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.051).clamp(16.0, 28.0).toDouble();

    return CupertinoPageScaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.left_chevron,
                size: 20,
                color: AppColors.getAccentColor(context),
              ),
              SizedBox(width: 4),
              AppText(
                'Back',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getAccentColor(context),
              ),
            ],
          ),
        ),
        middle: const AppText(
          'Edit Profile',
          variant: AppTextVariant.bodyLarge,
        ),
        backgroundColor: AppColors.getCardColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: ref
            .watch(userProvider)
            .when(
              data: (summery) => ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  const SizedBox(height: 24),
                  _buildAvatarSection(w),
                  const SizedBox(height: 32),
                  _buildEditForm(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('PREFERENCES', hPad),
                  _buildPreferencesSection(hPad),
                  const SizedBox(height: 32),
                  _buildActionButtons(hPad),
                  const SizedBox(height: 32),
                ],
              ),
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, stack) => const SizedBox.shrink(),
            ),
      ),
    );
  }

  Widget _buildAvatarSection(double w) {
    final avatarSize = (w * 0.28).clamp(100.0, 120.0);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final avatarBg = isDark ? AppColors.surfaceDark : const Color(0xFFEFF6FF);
    final avatarBorder = isDark
        ? AppColors.primaryGold
        : const Color(0xFFBFDBFE);
    final avatarIconColor = isDark
        ? AppColors.primaryGold
        : const Color(0xFF137FEC);
    final cameraBadgeColor = isDark
        ? AppColors.primaryGold
        : const Color(0xFF137FEC);
    final accentColor = AppColors.getAccentColor(context);
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg,
                border: Border.all(color: avatarBorder, width: 2),
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: avatarSize * 0.5,
                color: avatarIconColor,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cameraBadgeColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.camera_fill,
                  color: CupertinoColors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: AppText(
            'Change Profile Photo',
            variant: AppTextVariant.bodySmall,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    final user = ref.watch(userProvider).value?.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      color: AppColors.getCardColor(context),
      child: Column(
        children: [
          _buildNavigationRow(
            'Full Name',
            '${user.firstName} ${user.lastName}',
            () => Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => const EditNamePage())),
          ),
          const _Divider(leftPadding: 16),
          _buildNavigationRow(
            'Email',
            user.email,
            () => Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => const EditEmailPage())),
          ),
          const _Divider(leftPadding: 16),
          _buildNavigationRow(
            'Phone',
            user.phoneNumber,
            () => Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => const EditPhonePage())),
          ),
          const _Divider(leftPadding: 16),
          _buildPasswordRow(
            () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const ResetPasswordPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(String label, String value, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: AppText(
                label,
                variant: AppTextVariant.bodyMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Expanded(
              child: AppText(
                value,
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getTextSecondary(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRow(VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: AppText(
                'Password',
                variant: AppTextVariant.bodyMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Expanded(
              child: AppText(
                '••••••••',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 8),
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: AppColors.getTextSecondary(context),
      ),
    );
  }

  Widget _buildPreferencesSection(double hp) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hp),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Public Profile',
                  variant: AppTextVariant.bodyMedium,
                ),
                CupertinoSwitch(
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                  activeTrackColor: AppColors.getAccentColor(context),
                ),
              ],
            ),
          ),
          const _Divider(leftPadding: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Two-Factor Auth',
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.getTextPrimary(context),
                  ),
                  Row(
                    children: [
                      AppText(
                        'Enabled',
                        variant: AppTextVariant.bodySmall,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: Color(0xFFCBD5E1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double hp) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hp),
          child: CupertinoButton(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            onPressed: _showLogoutDialog,
            child: const SizedBox(
              width: double.infinity,
              child: Center(
                child: AppText(
                  'Sign Out',
                  variant: AppTextVariant.bodyMedium,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        CupertinoButton(
          padding: .zero,
          onPressed: () {},
          child: const AppText(
            'Freeze Account',
            variant: .bodySmall,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
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
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
}

class _Divider extends StatelessWidget {
  final double leftPadding;
  const _Divider({required this.leftPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Container(
        height: 0.5,
        color: AppColors.getSeparatorColor(context),
      ),
    );
  }
}
