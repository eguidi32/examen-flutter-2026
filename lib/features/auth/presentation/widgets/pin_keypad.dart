import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    super.key,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final keyValue = keys[index];
        if (keyValue.isEmpty) {
          return const SizedBox.shrink();
        }

        if (keyValue == 'del') {
          return _PinKey(
            semanticLabel: 'Effacer',
            icon: Icons.backspace_outlined,
            onTap: onBackspacePressed,
          );
        }

        return _PinKey(
          semanticLabel: 'Chiffre $keyValue',
          label: keyValue,
          onTap: () => onDigitPressed(keyValue),
        );
      },
    );
  }
}

class _PinKey extends StatefulWidget {
  const _PinKey({
    required this.semanticLabel,
    required this.onTap,
    this.label,
    this.icon,
  });

  final String semanticLabel;
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  State<_PinKey> createState() => _PinKeyState();
}

class _PinKeyState extends State<_PinKey> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          scale: _isPressed ? 0.96 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimaryDark.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: widget.icon == null
                  ? Text(widget.label!, style: AppTextStyles.headlineMedium)
                  : Icon(widget.icon, color: AppColors.inkMuted, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
