import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'widgets/bad_wallet_logo.dart';

class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BadWalletLogo(size: 72, showWordmark: false),
              const SizedBox(height: 24),
              Text('Session indisponible', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              BadWalletPrimaryButton(
                label: 'Reessayer',
                icon: Icons.refresh_rounded,
                onPressed: context.read<AuthProvider>().retryBootstrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
