import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_metrics.dart';
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
  bool _isSubmitting = false;

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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    await context.read<AuthProvider>().submitPhone(_phoneController.text);
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  void _startPin() {
    FocusScope.of(context).unfocus();
    context.read<AuthProvider>().startPinSetup(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BadWalletLogo(size: 82),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Connexion à BadWallet',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Entrez votre numéro de téléphone pour accéder à votre portefeuille en toute sécurité.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _PhoneInputShell(
                    controller: _phoneController,
                    onChanged: (_) {
                      if (_errorMessage == null) {
                        return;
                      }

                      setState(() => _errorMessage = null);
                    },
                  ),
                  AnimatedSwitcher(
                    duration: AppDurations.normal,
                    child: _errorMessage == null
                        ? const SizedBox(height: AppSpacing.lg)
                        : Padding(
                            key: const ValueKey('phone-error'),
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                  ),
                  BadWalletPrimaryButton(
                    label: 'Continuer',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _DividerWithText(label: 'ou'),
                  const SizedBox(height: AppSpacing.lg),
                  _PinOptionCard(onTap: _startPin),
                  const SizedBox(height: AppSpacing.xxxl),
                  BadWalletIconBadge(
                    icon: Icons.verified_user_rounded,
                    color: AppColors.brandPrimary,
                    backgroundColor: AppColors.brandPrimaryLight,
                    showBorder: false,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Vos données sont cryptées et sécurisées.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'En savoir plus',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.brandPrimary,
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

class _PhoneInputShell extends StatelessWidget {
  const _PhoneInputShell({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Text(
            'Numéro de téléphone',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.brandPrimary, width: 1.3),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              const Text('🇸🇳', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '+221',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.ink,
              ),
              Container(
                height: 32,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                color: AppColors.border,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                  ],
                  onChanged: onChanged,
                  cursorColor: AppColors.brandPrimary,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '77 123 45 67',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: AppTextStyles.labelLarge),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _PinOptionCard extends StatelessWidget {
  const _PinOptionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: double.infinity,
          padding: AppInsets.compactCard,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              BadWalletIconBadge(
                icon: Icons.fingerprint_rounded,
                color: AppColors.brandPrimary,
                backgroundColor: AppColors.brandPrimaryLight,
                size: 48,
                iconSize: 30,
                showBorder: false,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utiliser un code PIN ou biométrie',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Accédez rapidement et en toute sécurité',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
