import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bills/presentation/bills_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../transfers/presentation/transfer_screen.dart';
import '../data/dashboard_repository.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/recent_transactions_preview.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.phoneNumber,
    super.key,
    this.repository,
  });

  final String phoneNumber;
  final DashboardRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(
        phoneNumber: phoneNumber,
        repository: repository ?? ApiDashboardRepository(),
      )..load(),
      child: _DashboardView(phoneNumber: phoneNumber),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardProvider>().state;

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          DashboardLoading() => const _DashboardSkeleton(),
          DashboardError(:final message) => BadWalletErrorState(
            message: message,
            onRetry: context.read<DashboardProvider>().load,
          ),
          DashboardLoaded() => _DashboardLoadedView(
            phoneNumber: phoneNumber,
            state: state,
          ),
        },
      ),
    );
  }
}

class _DashboardLoadedView extends StatelessWidget {
  const _DashboardLoadedView({required this.phoneNumber, required this.state});

  final String phoneNumber;
  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: provider.refresh,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _DashboardHeader(phoneNumber: phoneNumber),
          const SizedBox(height: 18),
          BalanceCard(balance: state.balance),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  label: 'Transferer',
                  icon: Icons.send_rounded,
                  onTap: () => _openTransfer(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionButton(
                  label: 'Payer',
                  icon: Icons.receipt_long_rounded,
                  onTap: () => _openBills(context, state.balance.code),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionButton(
                  label: 'Historique',
                  icon: Icons.history_rounded,
                  onTap: () => _openHistory(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          RecentTransactionsPreview(
            transactions: state.transactions,
            phoneNumber: phoneNumber,
            onOpenHistory: () => _openHistory(context),
          ),
          if (state.isRefreshing) ...[
            const SizedBox(height: 14),
            Text(
              'Actualisation en cours...',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openTransfer(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransferScreen(phoneNumber: phoneNumber),
      ),
    );
    if (changed == true && context.mounted) {
      await context.read<DashboardProvider>().refresh();
    }
  }

  Future<void> _openBills(BuildContext context, String walletCode) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            BillsScreen(phoneNumber: phoneNumber, walletCode: walletCode),
      ),
    );
    if (changed == true && context.mounted) {
      await context.read<DashboardProvider>().refresh();
    }
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryScreen(phoneNumber: phoneNumber),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Connecte avec $phoneNumber',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Changer de numero',
          onPressed: context.read<AuthProvider>().clearSession,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        BadWalletSkeletonBox(width: 170, height: 34),
        SizedBox(height: 8),
        BadWalletSkeletonBox(width: 230, height: 18),
        SizedBox(height: 18),
        BadWalletSkeletonBox(width: double.infinity, height: 168),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: BadWalletSkeletonBox(width: double.infinity, height: 82),
            ),
            SizedBox(width: 10),
            Expanded(
              child: BadWalletSkeletonBox(width: double.infinity, height: 82),
            ),
            SizedBox(width: 10),
            Expanded(
              child: BadWalletSkeletonBox(width: double.infinity, height: 82),
            ),
          ],
        ),
        SizedBox(height: 18),
        BadWalletSkeletonBox(width: double.infinity, height: 340),
      ],
    );
  }
}
