import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'widgets/bad_wallet_logo.dart';
import 'widgets/pin_digit_indicator.dart';
import 'widgets/pin_keypad.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({
    required this.phoneNumber,
    required this.mode,
    super.key,
    this.errorMessage,
  });

  final String phoneNumber;
  final PinMode mode;
  final String? errorMessage;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const int _pinMaxLength = 6;

  String _pin = '';

  bool get _canSubmit => _pin.length >= 4 && _pin.length <= _pinMaxLength;

  String get _title {
    return switch (widget.mode) {
      PinMode.setup => 'Creez votre PIN',
      PinMode.unlock => 'Entrez votre PIN',
    };
  }

  String get _description {
    return switch (widget.mode) {
      PinMode.setup => 'Choisissez 4 a 6 chiffres pour securiser vos sessions.',
      PinMode.unlock => 'Session detectee pour ${widget.phoneNumber}.',
    };
  }

  String get _buttonLabel {
    return switch (widget.mode) {
      PinMode.setup => 'Creer le PIN',
      PinMode.unlock => 'Deverrouiller',
    };
  }

  @override
  void didUpdateWidget(covariant PinScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneNumber != widget.phoneNumber ||
        oldWidget.mode != widget.mode) {
      _pin = '';
    }
  }

  void _appendDigit(String digit) {
    if (_pin.length >= _pinMaxLength) {
      return;
    }

    context.read<AuthProvider>().clearPinError();
    setState(() => _pin += digit);
  }

  void _deleteDigit() {
    if (_pin.isEmpty) {
      return;
    }

    context.read<AuthProvider>().clearPinError();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    await context.read<AuthProvider>().submitPin(_pin);
    if (!mounted) {
      return;
    }

    final state = context.read<AuthProvider>().state;
    if (state is AuthPinEntry && state.errorMessage != null) {
      setState(() => _pin = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const BadWalletLogo(size: 64, showWordmark: false),
                  const SizedBox(height: 32),
                  Text(_title, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 8),
                  Text(_description, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 28),
                  BadWalletCard(
                    child: Column(
                      children: [
                        PinDigitIndicator(length: _pin.length),
                        const SizedBox(height: 12),
                        Text(
                          '4 chiffres minimum',
                          style: AppTextStyles.labelMedium,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: widget.errorMessage == null
                              ? const SizedBox(height: 24)
                              : Padding(
                                  key: const ValueKey('pin-error'),
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    widget.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        PinKeypad(
                          onDigitPressed: _appendDigit,
                          onBackspacePressed: _deleteDigit,
                        ),
                        const SizedBox(height: 20),
                        BadWalletPrimaryButton(
                          label: _buttonLabel,
                          icon: Icons.lock_open_rounded,
                          onPressed: _canSubmit ? _submit : null,
                        ),
                      ],
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
