import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';

class PinDigitIndicator extends StatelessWidget {
  const PinDigitIndicator({
    required this.length,
    super.key,
    this.maxLength = 6,
  });

  final int length;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < length;

        return AnimatedContainer(
          duration: AppDurations.normal,
          curve: Curves.easeOut,
          width: isFilled ? 14 : 12,
          height: isFilled ? 14 : 12,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isFilled ? AppColors.brandAccent : AppColors.surfaceMuted,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled ? AppColors.brandAccent : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}
