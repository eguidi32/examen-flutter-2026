import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/wallet_transaction.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../data/history_repository.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.phoneNumber, super.key, this.repository});

  final String phoneNumber;
  final HistoryRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryProvider(
        phoneNumber: phoneNumber,
        repository: repository ?? ApiHistoryRepository(),
      )..load(),
      child: _HistoryView(phoneNumber: phoneNumber),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HistoryProvider>().state;

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          HistoryLoading() => const _HistorySkeleton(),
          HistoryError(:final message) => BadWalletErrorState(
            message: message,
            onRetry: context.read<HistoryProvider>().load,
          ),
          HistoryLoaded(:final transactions) => _HistoryLoadedView(
            phoneNumber: phoneNumber,
            transactions: transactions,
          ),
        },
      ),
    );
  }
}

class _HistoryLoadedView extends StatelessWidget {
  const _HistoryLoadedView({
    required this.phoneNumber,
    required this.transactions,
  });

  final String phoneNumber;
  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupTransactions(transactions);

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: context.read<HistoryProvider>().load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          const SizedBox(height: 18),
          if (transactions.isEmpty)
            const SizedBox(
              height: 420,
              child: BadWalletEmptyState(
                title: 'Aucune transaction',
                message: 'Les mouvements de votre wallet apparaitront ici.',
                icon: Icons.receipt_long_rounded,
              ),
            )
          else
            ...grouped.entries.expand(
              (entry) => [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Text(entry.key, style: AppTextStyles.labelMedium),
                ),
                BadWalletCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      for (var index = 0; index < entry.value.length; index++)
                        Column(
                          children: [
                            TransactionListTile(
                              transaction: entry.value[index],
                              currentPhone: phoneNumber,
                            ),
                            if (index != entry.value.length - 1)
                              const Divider(),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Map<String, List<WalletTransaction>> _groupTransactions(
    List<WalletTransaction> transactions,
  ) {
    final grouped = <String, List<WalletTransaction>>{};
    for (final transaction in transactions) {
      final label = DateFormatter.groupLabel(transaction.createdAt);
      grouped.putIfAbsent(label, () => []).add(transaction);
    }
    return grouped;
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        BadWalletSkeletonBox(width: 170, height: 34),
        SizedBox(height: 24),
        BadWalletSkeletonBox(width: 120, height: 16),
        SizedBox(height: 10),
        BadWalletSkeletonBox(width: double.infinity, height: 76),
        SizedBox(height: 10),
        BadWalletSkeletonBox(width: double.infinity, height: 76),
        SizedBox(height: 20),
        BadWalletSkeletonBox(width: 120, height: 16),
        SizedBox(height: 10),
        BadWalletSkeletonBox(width: double.infinity, height: 76),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Retour',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Text('Historique', style: AppTextStyles.headlineLarge),
      ],
    );
  }
}
