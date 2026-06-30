import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import 'auth_error_screen.dart';
import 'phone_entry_screen.dart';
import 'pin_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.dashboardRepository});

  final DashboardRepository? dashboardRepository;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (authState) {
        AuthLoading() => const SplashScreen(key: ValueKey('splash')),
        AuthPhoneEntry(:final errorMessage) => PhoneEntryScreen(
          key: const ValueKey('phone-entry'),
          errorMessage: errorMessage,
        ),
        AuthPinEntry(:final phoneNumber, :final mode, :final errorMessage) =>
          PinScreen(
            key: ValueKey('pin-$phoneNumber-$mode'),
            phoneNumber: phoneNumber,
            mode: mode,
            errorMessage: errorMessage,
          ),
        AuthAuthenticated(:final phoneNumber) => DashboardScreen(
          key: const ValueKey('dashboard'),
          phoneNumber: phoneNumber,
          repository: dashboardRepository,
        ),
        AuthError(:final message) => AuthErrorScreen(
          key: const ValueKey('auth-error'),
          message: message,
        ),
      },
    );
  }
}
