import 'package:flutter/material.dart';

import '../../../../core/models/wallet_transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

class RecentTransactionsPreview extends StatelessWidget {
  const RecentTransactionsPreview({
    required this.transactions,
    required this.phoneNumber,
    required this.onOpenHistory,
    super.key,
  });

  final List<WalletTransaction> transactions;
  final String phoneNumber;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return BadWalletCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transactions récentes',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              InkWell(
                onTap: onOpenHistory,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    'Tout voir',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (transactions.isEmpty)
            const SizedBox(
              height: 190,
              child: BadWalletEmptyState(
                title: 'Aucune transaction',
                message: 'Vos 5 derniers mouvements apparaîtront ici.',
                icon: Icons.timeline_rounded,
              ),
            )
          else
            SizedBox(
              height: 300,
              child: Scrollbar(
                thumbVisibility: false,
                child: ListView.separated(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return TransactionListTile(
                      transaction: transactions[index],
                      currentPhone: phoneNumber,
                      compact: true,
                      onTap: onOpenHistory,
                    );
                  },
                  separatorBuilder: (_, _) =>
                      const Divider(color: AppColors.border),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
