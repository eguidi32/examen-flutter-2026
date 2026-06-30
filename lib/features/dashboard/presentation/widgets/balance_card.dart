import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/wallet_balance.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({required this.balance, super.key});

  final WalletBalance balance;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  void _toggleVisibility() {
    setState(() => _isVisible = !_isVisible);
  }

  @override
  Widget build(BuildContext context) {
    return BadWalletCard(
      backgroundColor: AppColors.brandPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Solde disponible',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
              IconButton(
                tooltip: _isVisible ? 'Masquer le solde' : 'Afficher le solde',
                onPressed: _toggleVisibility,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    _isVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    key: ValueKey(_isVisible),
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _isVisible
                  ? MoneyFormatter.format(
                      widget.balance.balance,
                      currency: widget.balance.currency,
                    )
                  : '********',
              key: ValueKey(_isVisible),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.balance.code,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.74),
            ),
          ),
        ],
      ),
    );
  }
}
