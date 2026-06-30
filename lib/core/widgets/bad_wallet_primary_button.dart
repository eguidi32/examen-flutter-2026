import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BadWalletPrimaryButton extends StatefulWidget {
  const BadWalletPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  State<BadWalletPrimaryButton> createState() => _BadWalletPrimaryButtonState();
}

class _BadWalletPrimaryButtonState extends State<BadWalletPrimaryButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value || !widget._isEnabled) {
      return;
    }

    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = widget._isEnabled
        ? AppColors.white
        : AppColors.inkSoft;

    return Semantics(
      button: true,
      enabled: widget._isEnabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget._isEnabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          scale: _isPressed ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: widget._isEnabled
                  ? AppColors.brandPrimary
                  : AppColors.border,
              gradient: widget._isEnabled ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget._isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.brandPrimary.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.isLoading
                  ? SizedBox(
                      key: const ValueKey('button-loader'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          foregroundColor,
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey('button-content'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20, color: foregroundColor),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: foregroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
