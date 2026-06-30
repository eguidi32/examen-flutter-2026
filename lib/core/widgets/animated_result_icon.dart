import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: color, size: 48),
          ),
        );
      },
    );
  }
}
