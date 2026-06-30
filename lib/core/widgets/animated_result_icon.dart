import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import 'bad_wallet_icon_badge.dart';

class AnimatedResultIcon extends StatelessWidget {
  const AnimatedResultIcon({required this.isSuccess, super.key});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.error;
    final background = isSuccess ? AppColors.successSoft : AppColors.errorSoft;
    final icon = isSuccess ? Icons.check_rounded : Icons.close_rounded;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: AppShadows.card,
            ),
            child: BadWalletIconBadge(
              icon: icon,
              color: color,
              backgroundColor: background,
              size: 88,
              iconSize: 46,
            ),
          ),
        );
      },
    );
  }
}
