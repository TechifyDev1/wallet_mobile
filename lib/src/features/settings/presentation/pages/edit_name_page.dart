import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/app_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/user/presentation/provider/user_provider.dart';

class EditNamePage extends ConsumerStatefulWidget {
  const EditNamePage({super.key});

  @override
  ConsumerState<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends ConsumerState<EditNamePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value?.user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackgroundColor(context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.getCardColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getSeparatorColor(context),
            width: 0.5,
          ),
        ),
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
              const SizedBox(width: 4),
              AppText(
                'Back',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.getAccentColor(context),
              ),
            ],
          ),
        ),
        middle: const AppText('Name', variant: AppTextVariant.bodyLarge),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: AppText(
            'Save',
            variant: AppTextVariant.bodyMedium,
            color: AppColors.getAccentColor(context),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              color: AppColors.getCardColor(context),
              child: Column(
                children: [
                  _buildField('First Name', _firstNameController),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      height: 0.5,
                      color: AppColors.getSeparatorColor(context),
                    ),
                  ),
                  _buildField('Last Name', _lastNameController),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppText(
                'Your name will be visible to other users when they search for you or see your transactions.',
                variant: AppTextVariant.caption,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextPrimary(context),
              ),
              placeholderStyle: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondary(context),
              ),
              padding: EdgeInsets.zero,
              decoration: null,
              autofocus: label == 'First Name',
            ),
          ),
        ],
      ),
    );
  }
}
