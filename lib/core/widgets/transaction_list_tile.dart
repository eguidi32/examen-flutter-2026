import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_formatter.dart';
import '../utils/money_formatter.dart';
import 'bad_wallet_icon_badge.dart';

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
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? AppSpacing.sm : AppSpacing.md,
          ),
          child: Row(
            children: [
              BadWalletIconBadge(
                icon: icon,
                color: toneColor,
                backgroundColor: toneBackground,
                showBorder: false,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.titleFor(currentPhone),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      transaction.subtitleFor(currentPhone),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MoneyFormatter.signedFormat(
                        transaction.amount,
                        isCredit: isCredit,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: toneColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${DateFormatter.groupLabel(transaction.createdAt)}, ${DateFormatter.time(transaction.createdAt)}',
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
