import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
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
      gradient: AppColors.balanceGradient,
      borderColor: AppColors.brandPrimary,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Solde du portefeuille',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: _isVisible ? 'Masquer le solde' : 'Afficher le solde',
                child: InkWell(
                  onTap: _toggleVisibility,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: AppDurations.normal,
                      child: Icon(
                        _isVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        key: ValueKey(_isVisible),
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppDurations.slow,
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                'Solde disponible',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.78),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  widget.balance.code,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
