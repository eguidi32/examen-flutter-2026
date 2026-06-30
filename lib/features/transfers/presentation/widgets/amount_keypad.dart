import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onClearPressed,
    super.key,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', 'del'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, index) {
        final keyValue = keys[index];
        if (keyValue == 'del') {
          return _AmountKey(
            semanticLabel: 'Effacer',
            icon: Icons.backspace_outlined,
            onTap: onBackspacePressed,
          );
        }
        if (keyValue == 'C') {
          return _AmountKey(
            semanticLabel: 'Vider',
            label: keyValue,
            onTap: onClearPressed,
          );
        }
        return _AmountKey(
          semanticLabel: 'Chiffre $keyValue',
          label: keyValue,
          onTap: () => onDigitPressed(keyValue),
        );
      },
    );
  }
}

class _AmountKey extends StatefulWidget {
  const _AmountKey({
    required this.semanticLabel,
    required this.onTap,
    this.label,
    this.icon,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final String? label;
  final IconData? icon;

  @override
  State<_AmountKey> createState() => _AmountKeyState();
}

class _AmountKeyState extends State<_AmountKey> {
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
            ),
            child: Center(
              child: widget.icon == null
                  ? Text(widget.label!, style: AppTextStyles.titleLarge)
                  : Icon(widget.icon, color: AppColors.inkMuted, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
