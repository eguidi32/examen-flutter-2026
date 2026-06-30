import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';

class BadWalletIconBadge extends StatelessWidget {
  const BadWalletIconBadge({
    required this.icon,
    super.key,
    this.color = AppColors.brandPrimary,
    this.backgroundColor = AppColors.brandPrimaryLight,
    this.size = 44,
    this.iconSize = 22,
    this.borderColor,
    this.showBorder = true,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final Color? borderColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.border)
            : null,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
