import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_metrics.dart';
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
      child: _DashboardShell(phoneNumber: phoneNumber),
    );
  }
}

class _DashboardShell extends StatefulWidget {
  const _DashboardShell({required this.phoneNumber});

  final String phoneNumber;

  @override
  State<_DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<_DashboardShell> {
  static const _navItems = [
    BadWalletNavItem(label: 'Accueil', icon: Icons.home_rounded),
    BadWalletNavItem(label: 'Transférer', icon: Icons.swap_horiz_rounded),
    BadWalletNavItem(label: 'Payer', icon: Icons.qr_code_scanner_rounded),
    BadWalletNavItem(label: 'Historique', icon: Icons.timeline_rounded),
  ];

  int _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleOperationCompleted(bool changed) async {
    setState(() => _selectedIndex = 0);
    if (changed && mounted) {
      await context.read<DashboardProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: AppDurations.slow,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _buildTab(context),
          ),
        ),
      ),
      bottomNavigationBar: BadWalletBottomNavigation(
        currentIndex: _selectedIndex,
        items: _navItems,
        onChanged: _selectTab,
      ),
    );
  }

  Widget _buildTab(BuildContext context) {
    return switch (_selectedIndex) {
      0 => _DashboardTab(
        phoneNumber: widget.phoneNumber,
        onOpenTransfer: () => _selectTab(1),
        onOpenBills: () => _selectTab(2),
        onOpenHistory: () => _selectTab(3),
      ),
      1 => _TransferTab(
        phoneNumber: widget.phoneNumber,
        onExit: () => _selectTab(0),
        onCompleted: _handleOperationCompleted,
      ),
      2 => _BillsTab(
        phoneNumber: widget.phoneNumber,
        onExit: () => _selectTab(0),
        onCompleted: _handleOperationCompleted,
      ),
      _ => HistoryScreen(
        phoneNumber: widget.phoneNumber,
        embedded: true,
        onExit: () => _selectTab(0),
      ),
    };
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.phoneNumber,
    required this.onOpenTransfer,
    required this.onOpenBills,
    required this.onOpenHistory,
  });

  final String phoneNumber;
  final VoidCallback onOpenTransfer;
  final VoidCallback onOpenBills;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardProvider>().state;

    return switch (state) {
      DashboardLoading() => const _DashboardSkeleton(),
      DashboardError(:final message) => BadWalletErrorState(
        message: message,
        onRetry: context.read<DashboardProvider>().load,
      ),
      DashboardLoaded() => _DashboardLoadedView(
        phoneNumber: phoneNumber,
        state: state,
        onOpenTransfer: onOpenTransfer,
        onOpenBills: onOpenBills,
        onOpenHistory: onOpenHistory,
      ),
    };
  }
}

class _DashboardLoadedView extends StatelessWidget {
  const _DashboardLoadedView({
    required this.phoneNumber,
    required this.state,
    required this.onOpenTransfer,
    required this.onOpenBills,
    required this.onOpenHistory,
  });

  final String phoneNumber;
  final DashboardLoaded state;
  final VoidCallback onOpenTransfer;
  final VoidCallback onOpenBills;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: provider.refresh,
      child: ListView(
        padding: AppInsets.screen,
        children: [
          _DashboardBrandHeader(
            onLogout: context.read<AuthProvider>().clearSession,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bonjour, Koffi 👋',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Gérez votre argent en toute simplicité',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          BalanceCard(balance: state.balance),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  label: 'Transférer',
                  icon: Icons.swap_horiz_rounded,
                  onTap: onOpenTransfer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: QuickActionButton(
                  label: 'Payer',
                  icon: Icons.receipt_long_rounded,
                  onTap: onOpenBills,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: QuickActionButton(
                  label: 'Historique',
                  icon: Icons.timeline_rounded,
                  onTap: onOpenHistory,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RecentTransactionsPreview(
            transactions: state.transactions,
            phoneNumber: phoneNumber,
            onOpenHistory: onOpenHistory,
          ),
          if (state.isRefreshing) ...[
            const SizedBox(height: AppSpacing.md),
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
}

class _BillsTab extends StatelessWidget {
  const _BillsTab({
    required this.phoneNumber,
    required this.onExit,
    required this.onCompleted,
  });

  final String phoneNumber;
  final VoidCallback onExit;
  final ValueChanged<bool> onCompleted;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardProvider>().state;

    return switch (state) {
      DashboardLoading() => const _FeatureLoading(
        title: 'Factures',
        subtitle: 'Preparation de votre portefeuille...',
        icon: Icons.receipt_long_rounded,
      ),
      DashboardError(:final message) => BadWalletErrorState(
        message: message,
        onRetry: context.read<DashboardProvider>().load,
      ),
      DashboardLoaded(:final balance) => BillsScreen(
        phoneNumber: phoneNumber,
        walletCode: balance.code,
        embedded: true,
        onExit: onExit,
        onCompleted: onCompleted,
      ),
    };
  }
}

class _TransferTab extends StatelessWidget {
  const _TransferTab({
    required this.phoneNumber,
    required this.onExit,
    required this.onCompleted,
  });

  final String phoneNumber;
  final VoidCallback onExit;
  final ValueChanged<bool> onCompleted;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardProvider>().state;

    return switch (state) {
      DashboardLoading() => const _FeatureLoading(
        title: 'Transférer',
        subtitle: 'Préparation de votre solde...',
        icon: Icons.swap_horiz_rounded,
      ),
      DashboardError(:final message) => BadWalletErrorState(
        message: message,
        onRetry: context.read<DashboardProvider>().load,
      ),
      DashboardLoaded(:final balance) => TransferScreen(
        phoneNumber: phoneNumber,
        availableBalance: balance.balance,
        currency: balance.currency,
        embedded: true,
        onExit: onExit,
        onCompleted: onCompleted,
      ),
    };
  }
}

class _FeatureLoading extends StatelessWidget {
  const _FeatureLoading({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppInsets.screen,
      children: [
        BadWalletHeader(title: title, subtitle: subtitle, icon: icon),
        const SizedBox(height: AppSpacing.lg),
        const BadWalletSkeletonBox(width: double.infinity, height: 92),
        const SizedBox(height: AppSpacing.md),
        const BadWalletSkeletonBox(width: double.infinity, height: 76),
        const SizedBox(height: AppSpacing.sm),
        const BadWalletSkeletonBox(width: double.infinity, height: 76),
      ],
    );
  }
}

class _DashboardBrandHeader extends StatelessWidget {
  const _DashboardBrandHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppAssets.badWalletLogo,
          width: 54,
          height: 54,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
              children: const [
                TextSpan(
                  text: 'Bad',
                  style: TextStyle(color: AppColors.ink),
                ),
                TextSpan(
                  text: 'Wallet',
                  style: TextStyle(color: AppColors.brandAccentMuted),
                ),
              ],
            ),
          ),
        ),
        _NotificationButton(),
        const SizedBox(width: AppSpacing.sm),
        _AvatarButton(onTap: onLogout),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.ink,
          ),
        ),
        Positioned(
          right: 7,
          top: 6,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.brandAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: AppColors.brandPrimaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_rounded,
          color: AppColors.brandPrimary,
          size: 30,
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppInsets.screen,
      children: const [
        BadWalletSkeletonBox(width: 190, height: 64),
        SizedBox(height: AppSpacing.md),
        BadWalletSkeletonBox(width: double.infinity, height: 178),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: BadWalletSkeletonBox(width: double.infinity, height: 88),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: BadWalletSkeletonBox(width: double.infinity, height: 88),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: BadWalletSkeletonBox(width: double.infinity, height: 88),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        BadWalletSkeletonBox(width: double.infinity, height: 340),
      ],
    );
  }
}
