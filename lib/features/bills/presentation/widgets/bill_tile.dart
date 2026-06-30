import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../data/bill.dart';

class BillTile extends StatelessWidget {
  const BillTile({
    required this.bill,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  final Bill bill;
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            _CustomCheckbox(isSelected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Echeance ${DateFormatter.day(bill.dueDate)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              MoneyFormatter.format(bill.amount),
              textAlign: TextAlign.right,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
          ],
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
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.brandPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(7),
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
