import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class DashboardPlaceholderScreen extends StatelessWidget {
  const DashboardPlaceholderScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Dashboard', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Placeholder temporaire, la feature dashboard arrive ensuite.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              BadWalletCard(
                backgroundColor: AppColors.brandPrimaryLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.appName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Connecte avec $phoneNumber',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BadWalletPrimaryButton(
                label: 'Changer de numero',
                icon: Icons.logout_rounded,
                onPressed: context.read<AuthProvider>().clearSession,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
