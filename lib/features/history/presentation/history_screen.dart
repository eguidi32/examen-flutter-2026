import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../data/history_repository.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.phoneNumber,
    super.key,
    this.repository,
    this.embedded = false,
    this.onExit,
  });

  final String phoneNumber;
  final HistoryRepository? repository;
  final bool embedded;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryProvider(
        phoneNumber: phoneNumber,
        repository: repository ?? ApiHistoryRepository(),
      )..load(),
      child: _HistoryView(
        phoneNumber: phoneNumber,
        embedded: embedded,
        onExit: onExit,
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.phoneNumber,
    required this.embedded,
    this.onExit,
  });

  final String phoneNumber;
  final bool embedded;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HistoryProvider>().state;

    final content = switch (state) {
      HistoryLoading() => const _HistorySkeleton(),
      HistoryError(:final message) => BadWalletErrorState(
        message: message,
        onRetry: context.read<HistoryProvider>().load,
      ),
      HistoryLoaded() => _HistoryLoadedView(
        phoneNumber: phoneNumber,
        state: state,
        onExit: onExit ?? () => Navigator.of(context).maybePop(),
      ),
    };

    if (embedded) {
      return content;
    }

    return Scaffold(body: SafeArea(child: content));
  }
}

class _HistoryLoadedView extends StatelessWidget {
  const _HistoryLoadedView({
    required this.phoneNumber,
    required this.state,
    required this.onExit,
  });

  final String phoneNumber;
  final HistoryLoaded state;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: context.read<HistoryProvider>().load,
      child: ListView(
        padding: AppInsets.screen,
        children: [
          BadWalletHeader(
            title: 'Historique',
            onBack: onExit,
            trailing: BadWalletIconBadge(
              icon: Icons.filter_alt_outlined,
              color: AppColors.brandPrimary,
              backgroundColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SearchBox(
            initialValue: state.query,
            onChanged: context.read<HistoryProvider>().updateQuery,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _FilterPill(
                label: 'Tout',
                isSelected: state.filter == HistoryFilter.all,
                color: AppColors.brandPrimary,
                onTap: () => context.read<HistoryProvider>().updateFilter(
                  HistoryFilter.all,
                ),
              ),
              _FilterPill(
                label: 'Entrées',
                isSelected: state.filter == HistoryFilter.credits,
                color: AppColors.success,
                onTap: () => context.read<HistoryProvider>().updateFilter(
                  HistoryFilter.credits,
                ),
              ),
              _FilterPill(
                label: 'Sorties',
                isSelected: state.filter == HistoryFilter.debits,
                color: AppColors.error,
                onTap: () => context.read<HistoryProvider>().updateFilter(
                  HistoryFilter.debits,
                ),
              ),
              _PeriodPill(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.transactions.isEmpty)
            const SizedBox(
              height: 420,
              child: BadWalletEmptyState(
                title: 'Aucune transaction',
                message: 'Aucun mouvement ne correspond à votre recherche.',
                icon: Icons.receipt_long_rounded,
              ),
            )
          else
            BadWalletCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < state.transactions.length;
                    index++
                  )
                    Column(
                      children: [
                        TransactionListTile(
                          transaction: state.transactions[index],
                          currentPhone: phoneNumber,
                        ),
                        if (index != state.transactions.length - 1)
                          const Divider(),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.inkMuted,
          ),
          hintText: 'Rechercher une transaction...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.inkSoft,
          ),
          contentPadding: AppInsets.field,
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: isSelected ? color : AppColors.border),
          boxShadow: isSelected ? AppShadows.colored(color) : AppShadows.card,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : color,
          ),
        ),
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.inkMuted,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text('01 Mai - 31 Mai', style: AppTextStyles.labelMedium),
          const SizedBox(width: AppSpacing.xxs),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.inkMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppInsets.screen,
      children: const [
        BadWalletSkeletonBox(width: 170, height: 34),
        SizedBox(height: AppSpacing.xl),
        BadWalletSkeletonBox(width: 120, height: 16),
        SizedBox(height: AppSpacing.sm),
        BadWalletSkeletonBox(width: double.infinity, height: 76),
        SizedBox(height: AppSpacing.sm),
        BadWalletSkeletonBox(width: double.infinity, height: 76),
        SizedBox(height: AppSpacing.lg),
        BadWalletSkeletonBox(width: 120, height: 16),
        SizedBox(height: AppSpacing.sm),
        BadWalletSkeletonBox(width: double.infinity, height: 76),
      ],
    );
  }
}
