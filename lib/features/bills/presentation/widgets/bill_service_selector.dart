import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BillService.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 94,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_serviceIcon(service), color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              service.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.brandPrimary : AppColors.inkMuted,
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
      BillService.rapido => AppColors.success,
      BillService.senelec => AppColors.error,
    };
  }
}
