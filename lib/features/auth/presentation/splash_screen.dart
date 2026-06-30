import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import 'widgets/bad_wallet_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BadWalletLogo(size: 88),
                  const SizedBox(height: 12),
                  Text(
                    'Votre wallet, simplement.',
                    style: AppTextStyles.bodyMedium,
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
