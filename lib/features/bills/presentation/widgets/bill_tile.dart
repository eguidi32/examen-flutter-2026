import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../data/bill.dart';
import '../../data/bill_service.dart';

class BillTile extends StatelessWidget {
  const BillTile({
    required this.bill,
    required this.service,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  final Bill bill;
  final BillService service;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!isSelected);
      },
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOut,
        padding: AppInsets.compactCard,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected ? AppColors.brandAccent : AppColors.border,
          ),
          boxShadow: isSelected ? AppShadows.accent : AppShadows.card,
        ),
        child: Row(
          children: [
            _CustomCheckbox(isSelected: isSelected),
            const SizedBox(width: AppSpacing.md),
            _ServiceMark(service: service),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    service.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Client : ${bill.walletCode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  MoneyFormatter.format(bill.amount),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Échéance : ${DateFormatter.day(bill.dueDate)}',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceMark extends StatelessWidget {
  const _ServiceMark({required this.service});

  final BillService service;

  @override
  Widget build(BuildContext context) {
    final color = switch (service) {
      BillService.ism => AppColors.brandPrimary,
      BillService.woyafal => AppColors.warning,
      BillService.rapido => AppColors.brandPrimary,
      BillService.senelec => AppColors.error,
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          service.label.substring(0, 1),
          style: AppTextStyles.titleMedium.copyWith(color: color),
        ),
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  const _CustomCheckbox({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.brandPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isSelected ? AppColors.brandPrimary : AppColors.border,
          width: 1.4,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 140),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey('checked'),
                color: AppColors.white,
                size: 18,
              )
            : const SizedBox(key: ValueKey('unchecked')),
      ),
    );
  }
}
