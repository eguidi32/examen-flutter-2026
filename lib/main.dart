import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/data/dashboard_repository.dart';

void main() {
  runApp(const BadWalletApp());
}

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({
    super.key,
    this.authRepository,
    this.dashboardRepository,
  });

  final AuthRepository? authRepository;
  final DashboardRepository? dashboardRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AuthProvider(authRepository: authRepository ?? SecureAuthRepository())
            ..bootstrap(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: AuthGate(dashboardRepository: dashboardRepository),
      ),
    );
  }
}
