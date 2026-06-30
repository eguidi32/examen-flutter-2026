import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/bill_service.dart';

class BillServiceSelector extends StatelessWidget {
  const BillServiceSelector({
    required this.selectedService,
    required this.onSelected,
    super.key,
  });

  final BillService selectedService;
  final ValueChanged<BillService> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BillService.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final service = BillService.values[index];
          final isSelected = service == selectedService;

          return _ServiceChip(
            service: service,
            isSelected: isSelected,
            onTap: () => onSelected(service),
          );
        },
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final BillService service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _serviceColor(service);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOut,
        width: 108,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected ? AppColors.brandAccent : AppColors.border,
          ),
          boxShadow: isSelected ? AppShadows.accent : AppShadows.none,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BadWalletIconBadge(
              icon: _serviceIcon(service),
              color: color,
              backgroundColor: isSelected
                  ? AppColors.brandAccentSoft
                  : AppColors.surfaceMuted,
              size: 36,
              iconSize: 20,
              showBorder: false,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              service.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              service.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(BillService service) {
    return switch (service) {
      BillService.ism => Icons.school_rounded,
      BillService.woyafal => Icons.bolt_rounded,
      BillService.rapido => Icons.directions_bus_rounded,
      BillService.senelec => Icons.lightbulb_rounded,
    };
  }

  Color _serviceColor(BillService service) {
    return switch (service) {
      BillService.ism => AppColors.brandPrimary,
      BillService.woyafal => AppColors.warning,
      BillService.rapido => AppColors.brandAccentMuted,
      BillService.senelec => AppColors.brandPrimaryDark,
    };
  }
}
