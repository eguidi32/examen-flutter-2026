import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    super.key,
    this.onSeparatorPressed,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onSeparatorPressed;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', ',', '0', 'del'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
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
        if (keyValue == ',') {
          return _AmountKey(
            semanticLabel: 'Virgule',
            label: keyValue,
            onTap: onSeparatorPressed ?? () {},
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
          duration: AppDurations.quick,
          curve: Curves.easeOut,
          scale: _isPressed ? 0.96 : 1,
          child: AnimatedContainer(
            duration: AppDurations.normal,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
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
