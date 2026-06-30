import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadii {
  const AppRadii._();

  static const double sm = 6;
  static const double md = 8;
  static const double lg = 8;
  static const double pill = 999;
}

class AppDurations {
  const AppDurations._();

  static const Duration quick = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
}

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14022A25), blurRadius: 20, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> lifted = [
    BoxShadow(color: Color(0x1F022A25), blurRadius: 24, offset: Offset(0, 14)),
  ];

  static const List<BoxShadow> accent = [
    BoxShadow(color: Color(0x33FFB84D), blurRadius: 18, offset: Offset(0, 10)),
  ];

  static List<BoxShadow> colored(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.22),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static const List<BoxShadow> none = [];
}

class AppInsets {
  const AppInsets._();

  static const EdgeInsets screen = EdgeInsets.all(AppSpacing.xl);
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets compactCard = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets field = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );
  static const EdgeInsets bottomNav = EdgeInsets.fromLTRB(
    AppSpacing.sm,
    AppSpacing.xs,
    AppSpacing.sm,
    AppSpacing.sm,
  );
}
