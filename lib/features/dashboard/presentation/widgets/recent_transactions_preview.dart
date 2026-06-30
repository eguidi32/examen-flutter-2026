import 'package:flutter/material.dart';

import '../../../../core/models/wallet_transaction.dart';
import '../../../../core/theme/app_colors.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dernieres transactions',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              TextButton(
                onPressed: onOpenHistory,
                child: const Text('Tout voir'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if (transactions.isEmpty)
            const SizedBox(
              height: 190,
              child: BadWalletEmptyState(
                title: 'Aucune transaction',
                message: 'Vos 5 derniers mouvements apparaitront ici.',
                icon: Icons.receipt_long_rounded,
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
