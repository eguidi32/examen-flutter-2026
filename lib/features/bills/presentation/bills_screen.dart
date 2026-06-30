import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../data/bill_payment_result.dart';
import '../data/bills_repository.dart';
import '../providers/bills_provider.dart';
import 'widgets/bill_service_selector.dart';
import 'widgets/bill_tile.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({
    required this.phoneNumber,
    required this.walletCode,
    super.key,
    this.repository,
    this.embedded = false,
    this.onExit,
    this.onCompleted,
  });

  final String phoneNumber;
  final String walletCode;
  final BillsRepository? repository;
  final bool embedded;
  final VoidCallback? onExit;
  final ValueChanged<bool>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillsProvider(
        phoneNumber: phoneNumber,
        walletCode: walletCode,
        repository: repository ?? ApiBillsRepository(),
      )..load(),
      child: _BillsFlow(
        embedded: embedded,
        onExit: onExit,
        onCompleted: onCompleted,
      ),
    );
  }
}

enum _BillsStep { list, confirmation, result }

class _BillsFlow extends StatefulWidget {
  const _BillsFlow({required this.embedded, this.onExit, this.onCompleted});

  final bool embedded;
  final VoidCallback? onExit;
  final ValueChanged<bool>? onCompleted;

  @override
  State<_BillsFlow> createState() => _BillsFlowState();
}

class _BillsFlowState extends State<_BillsFlow> {
  _BillsStep _step = _BillsStep.list;
  bool _resultSuccess = false;
  String _resultMessage = '';
  BillPaymentResult? _paymentResult;

  void _goToConfirmation() {
    setState(() => _step = _BillsStep.confirmation);
  }

  Future<void> _confirmPayment() async {
    HapticFeedback.mediumImpact();
    final provider = context.read<BillsProvider>();

    try {
      final result = await provider.paySelected();
      if (result == null) {
        return;
      }

      setState(() {
        _paymentResult = result;
        _resultSuccess = true;
        _resultMessage = result.message;
        _step = _BillsStep.result;
      });
    } on ApiException catch (exception) {
      setState(() {
        _paymentResult = null;
        _resultSuccess = false;
        _resultMessage = exception.message;
        _step = _BillsStep.result;
      });
    }
  }

  void _closeResult() {
    if (widget.onCompleted != null) {
      widget.onCompleted!(_resultSuccess);
      return;
    }
    Navigator.of(context).pop(_resultSuccess);
  }

  void _exit() {
    if (widget.onExit != null) {
      widget.onExit!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedSwitcher(
      duration: AppDurations.slow,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (_step) {
        _BillsStep.list => _BillsList(
          key: const ValueKey('bills-list'),
          onExit: _exit,
          onContinue: _goToConfirmation,
        ),
        _BillsStep.confirmation => _BillsConfirmation(
          key: const ValueKey('bills-confirmation'),
          onBack: () => setState(() => _step = _BillsStep.list),
          onConfirm: _confirmPayment,
        ),
        _BillsStep.result => _BillsResult(
          key: const ValueKey('bills-result'),
          isSuccess: _resultSuccess,
          message: _resultMessage,
          result: _paymentResult,
          onDone: _closeResult,
          onRetry: () => setState(() => _step = _BillsStep.list),
        ),
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(body: SafeArea(child: content));
  }
}

class _BillsList extends StatelessWidget {
  const _BillsList({required this.onExit, required this.onContinue, super.key});

  final VoidCallback onExit;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BillsProvider>().state;

    return switch (state) {
      BillsLoading() => const _BillsSkeleton(),
      BillsError(:final message) => BadWalletErrorState(
        message: message,
        onRetry: () => context.read<BillsProvider>().load(),
      ),
      BillsLoaded() => _BillsLoadedView(
        state: state,
        onExit: onExit,
        onContinue: onContinue,
      ),
    };
  }
}

class _BillsLoadedView extends StatelessWidget {
  const _BillsLoadedView({
    required this.state,
    required this.onExit,
    required this.onContinue,
  });

  final BillsLoaded state;
  final VoidCallback onExit;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BillsProvider>();

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.brandPrimary,
          onRefresh: () => provider.load(service: state.service),
          child: ListView(
            padding: AppInsets.screen.copyWith(bottom: 178),
            children: [
              BadWalletHeader(
                title: 'Paiement de factures',
                onBack: onExit,
                trailing: BadWalletIconBadge(
                  icon: Icons.notifications_none_rounded,
                  color: AppColors.ink,
                  backgroundColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fournisseurs',
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                  Text(
                    'Voir tout',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              BillServiceSelector(
                selectedService: state.service,
                onSelected: provider.selectService,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Text('Factures impayées', style: AppTextStyles.titleMedium),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimaryLight,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      '${state.bills.length}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: state.bills.isEmpty
                        ? null
                        : provider.toggleSelectAll,
                    child: Text(
                      state.allSelected
                          ? 'Tout désélectionner'
                          : 'Tout sélectionner',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.bills.isEmpty)
                const SizedBox(
                  height: 280,
                  child: BadWalletEmptyState(
                    title: 'Aucune facture',
                    message: 'Aucune facture impayée pour ce fournisseur.',
                    icon: Icons.receipt_long_rounded,
                  ),
                )
              else
                ...state.bills.map(
                  (bill) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: BillTile(
                      bill: bill,
                      service: state.service,
                      isSelected: state.selectedReferences.contains(
                        bill.reference,
                      ),
                      onChanged: (_) => provider.toggleBill(bill.reference),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              _SecurityCard(),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _PaymentBar(
            count: state.selectedReferences.length,
            total: state.selectedTotal,
            isLoading: state.isPaying,
            onPressed: state.hasSelection ? onContinue : null,
          ),
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: AppColors.brandPrimaryLight,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          BadWalletIconBadge(
            icon: Icons.shield_outlined,
            color: AppColors.brandPrimary,
            backgroundColor: AppColors.surface,
            showBorder: false,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paiement 100% sécurisé', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Vos paiements sont protégés par un chiffrement de bout en bout.',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.brandPrimary,
          ),
        ],
      ),
    );
  }
}

class _PaymentBar extends StatelessWidget {
  const _PaymentBar({
    required this.count,
    required this.total,
    required this.isLoading,
    required this.onPressed,
  });

  final int count;
  final double total;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
        boxShadow: AppShadows.lifted,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$count facture${count > 1 ? 's' : ''} sélectionnée${count > 1 ? 's' : ''}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                Text(
                  MoneyFormatter.format(total),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total à payer',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                Text(
                  MoneyFormatter.format(total),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            BadWalletPrimaryButton(
              label: 'Payer la sélection',
              icon: Icons.arrow_forward_rounded,
              isLoading: isLoading,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _BillsConfirmation extends StatelessWidget {
  const _BillsConfirmation({
    required this.onBack,
    required this.onConfirm,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BillsProvider>().state;
    if (state is! BillsLoaded) {
      return const _BillsSkeleton();
    }

    return ListView(
      padding: AppInsets.screen,
      children: [
        BadWalletHeader(
          title: 'Confirmation',
          subtitle: 'Paiement groupe des factures selectionnees.',
          onBack: onBack,
        ),
        const SizedBox(height: AppSpacing.lg),
        BadWalletCard(
          child: Column(
            children: [
              _SummaryRow(label: 'Fournisseur', value: state.service.label),
              const Divider(),
              _SummaryRow(
                label: 'Factures',
                value: '${state.selectedReferences.length}',
              ),
              const Divider(),
              _SummaryRow(
                label: 'Total',
                value: MoneyFormatter.format(state.selectedTotal),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.bills
            .where((bill) => state.selectedReferences.contains(bill.reference))
            .map(
              (bill) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: BadWalletCard(
                  padding: AppInsets.compactCard,
                  child: _SummaryRow(
                    label: bill.reference,
                    value: MoneyFormatter.format(bill.amount),
                  ),
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
        BadWalletPrimaryButton(
          label: 'Confirmer le paiement',
          icon: Icons.verified_rounded,
          isLoading: state.isPaying,
          onPressed: state.isPaying ? null : onConfirm,
        ),
      ],
    );
  }
}

class _BillsResult extends StatelessWidget {
  const _BillsResult({
    required this.isSuccess,
    required this.message,
    required this.onDone,
    required this.onRetry,
    this.result,
    super.key,
  });

  final bool isSuccess;
  final String message;
  final BillPaymentResult? result;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.screen,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedResultIcon(isSuccess: isSuccess),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isSuccess ? 'Paiement reussi' : 'Paiement echoue',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              if (result != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  MoneyFormatter.format(result!.totalAmount),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              BadWalletPrimaryButton(
                label: isSuccess ? 'Retour au dashboard' : 'Modifier',
                icon: isSuccess ? Icons.home_rounded : Icons.edit_rounded,
                onPressed: isSuccess ? onDone : onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillsSkeleton extends StatelessWidget {
  const _BillsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppInsets.screen,
      children: const [
        BadWalletSkeletonBox(width: 180, height: 34),
        SizedBox(height: AppSpacing.lg),
        BadWalletSkeletonBox(width: double.infinity, height: 92),
        SizedBox(height: AppSpacing.md),
        BadWalletSkeletonBox(width: double.infinity, height: 78),
        SizedBox(height: AppSpacing.sm),
        BadWalletSkeletonBox(width: double.infinity, height: 78),
        SizedBox(height: AppSpacing.sm),
        BadWalletSkeletonBox(width: double.infinity, height: 78),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
