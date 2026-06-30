import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';

class BadWalletLogo extends StatelessWidget {
  const BadWalletLogo({super.key, this.size = 72, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final logoSize = showWordmark ? size * 2.45 : size * 1.3;

    return Image.asset(
      AppAssets.badWalletLogo,
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
      semanticLabel: AppStrings.appName,
      filterQuality: FilterQuality.high,
    );
  }
}
