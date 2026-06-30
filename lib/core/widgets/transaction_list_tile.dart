import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_formatter.dart';
import '../utils/money_formatter.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    required this.transaction,
    required this.currentPhone,
    super.key,
    this.onTap,
    this.compact = false,
  });

  final WalletTransaction transaction;
  final String currentPhone;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCreditFor(currentPhone);
    final toneColor = isCredit ? AppColors.success : AppColors.error;
    final toneBackground = isCredit
        ? AppColors.successSoft
        : AppColors.errorSoft;
    final icon = isCredit ? Icons.south_west_rounded : Icons.north_east_rounded;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: toneBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: toneColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.titleFor(currentPhone),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.time(transaction.createdAt),
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.subtitleFor(currentPhone),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 118),
                child: Text(
                  MoneyFormatter.signedFormat(
                    transaction.amount,
                    isCredit: isCredit,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(color: toneColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
