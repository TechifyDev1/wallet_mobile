import 'package:flutter/cupertino.dart';
import '../constants/app_colors.dart';

/// A horizontal divider with a label, used between auth options.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'Or'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.iosSeparator.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const .symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.iosTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.iosSeparator.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
