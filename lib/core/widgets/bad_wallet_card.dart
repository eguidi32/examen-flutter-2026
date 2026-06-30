import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';

class BadWalletCard extends StatelessWidget {
  const BadWalletCard({
    required this.child,
    super.key,
    this.padding = AppInsets.card,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.gradient,
    this.borderColor = AppColors.border,
    this.isElevated = true,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color borderColor;
  final bool isElevated;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: showBorder ? Border.all(color: borderColor) : null,
        boxShadow: isElevated ? AppShadows.card : AppShadows.none,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: card,
    );
  }
}
