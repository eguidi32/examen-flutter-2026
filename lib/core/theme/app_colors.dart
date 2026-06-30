import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color brandPrimary = Color(0xFF0B5B45);
  static const Color brandPrimaryDark = Color(0xFF073C2F);
  static const Color brandPrimaryLight = Color(0xFFE4F8F1);
  static const Color brandAccent = Color(0xFF25D6A2);
  static const Color brandAccentSoft = Color(0xFFDDFBF1);

  static const Color ink = Color(0xFF10231D);
  static const Color inkMuted = Color(0xFF5C6F68);
  static const Color inkSoft = Color(0xFF83928D);

  static const Color background = Color(0xFFF6FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF6F3);
  static const Color border = Color(0xFFD9E7E2);

  static const Color success = Color(0xFF12A16B);
  static const Color successSoft = Color(0xFFE6F7EF);
  static const Color error = Color(0xFFE5484D);
  static const Color errorSoft = Color(0xFFFFEDEE);
  static const Color warning = Color(0xFFF5A524);
  static const Color warningSoft = Color(0xFFFFF6DB);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPrimary, brandAccent],
  );
}
