import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReceiverAvatar extends StatelessWidget {
  const ReceiverAvatar({required this.phoneNumber, super.key, this.size = 54});

  final String phoneNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = _initials(phoneNumber);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.brandAccentSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.brandAccent),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Text(
            label,
            key: ValueKey(label),
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 2) {
      return digits.substring(digits.length - 2);
    }
    if (digits.isNotEmpty) {
      return digits;
    }
    return 'BW';
  }
}
