import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'widgets/bad_wallet_logo.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  late final TextEditingController _phoneController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _errorMessage = widget.errorMessage;
  }

  @override
  void didUpdateWidget(covariant PhoneEntryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorMessage != widget.errorMessage) {
      _errorMessage = widget.errorMessage;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthProvider>().submitPhone(_phoneController.text);
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
                  Text('Votre numero', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Ce numero servira d identifiant principal pour vos appels wallet.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  BadWalletCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BadWalletTextField(
                          label: 'Numero de telephone',
                          controller: _phoneController,
                          hintText: '+221 77 000 00 00',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.phone_rounded,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\s\-().]'),
                            ),
                          ],
                          onChanged: (_) {
                            if (_errorMessage == null) {
                              return;
                            }

                            setState(() => _errorMessage = null);
                          },
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _errorMessage == null
                              ? const SizedBox(height: 16)
                              : Padding(
                                  key: const ValueKey('phone-error'),
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        BadWalletPrimaryButton(
                          label: 'Continuer',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _submit,
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
