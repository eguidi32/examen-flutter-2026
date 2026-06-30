import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color brandPrimary = Color(0xFF0057FF);
  static const Color brandPrimaryDark = Color(0xFF061D63);
  static const Color brandPrimaryLight = Color(0xFFEAF1FF);
  static const Color brandAccent = Color(0xFF10C8C7);
  static const Color brandAccentSoft = Color(0xFFE6FBFB);
  static const Color brandAccentMuted = Color(0xFF079FA0);

  static const Color ink = Color(0xFF07133F);
  static const Color inkMuted = Color(0xFF66718D);
  static const Color inkSoft = Color(0xFF98A3BA);

  static const Color background = Color(0xFFF7FAFF);
  static const Color backgroundRaised = Color(0xFFEFF5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF3FB);
  static const Color surfacePressed = Color(0xFFE3ECFA);
  static const Color border = Color(0xFFD8E2F1);

  static const Color success = Color(0xFF10B95F);
  static const Color successSoft = Color(0xFFE8F9EF);
  static const Color error = Color(0xFFFF2438);
  static const Color errorSoft = Color(0xFFFFEDF0);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF4D8);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B7BFF), brandPrimary, Color(0xFF0044D9)],
  );

  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF126BFF), brandPrimary, Color(0xFF0037B8)],
  );
}
