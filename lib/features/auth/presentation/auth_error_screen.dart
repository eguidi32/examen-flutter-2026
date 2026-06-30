import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppInsets.screen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BadWalletBrandPanel(
                title: 'BadWallet',
                subtitle:
                    'Le service de session est momentanement indisponible.',
                compact: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Session indisponible', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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
