import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../data/bill_payment_result.dart';
import '../data/bill_service.dart';
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
  });

  final String phoneNumber;
  final String walletCode;
  final BillsRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillsProvider(
        phoneNumber: phoneNumber,
        walletCode: walletCode,
        repository: repository ?? ApiBillsRepository(),
      )..load(),
      child: const _BillsFlow(),
    );
  }
}

enum _BillsStep { list, confirmation, result }

class _BillsFlow extends StatefulWidget {
  const _BillsFlow();

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
    Navigator.of(context).pop(_resultSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: switch (_step) {
            _BillsStep.list => _BillsList(
              key: const ValueKey('bills-list'),
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
        ),
      ),
    );
  }
}

class _BillsList extends StatelessWidget {
  const _BillsList({required this.onContinue, super.key});

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
      BillsLoaded() => _BillsLoadedView(state: state, onContinue: onContinue),
    };
  }
}

class _BillsLoadedView extends StatelessWidget {
  const _BillsLoadedView({required this.state, required this.onContinue});

  final BillsLoaded state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BillsProvider>();

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: () => provider.load(service: state.service),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ScreenHeader(
            title: 'Payer',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 16),
          BillServiceSelector(
            selectedService: state.service,
            onSelected: provider.selectService,
          ),
          const SizedBox(height: 16),
          if (state.bills.isEmpty)
            const SizedBox(
              height: 280,
              child: BadWalletEmptyState(
                title: 'Aucune facture',
                message: 'Aucune facture impayee pour ce fournisseur.',
                icon: Icons.receipt_long_rounded,
              ),
            )
          else ...[
            Text('Factures du mois', style: AppTextStyles.titleMedium),
            const SizedBox(height: 10),
            ...state.bills.map(
              (bill) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BillTile(
                  bill: bill,
                  isSelected: state.selectedReferences.contains(bill.reference),
                  onChanged: (_) => provider.toggleBill(bill.reference),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          BadWalletCard(
            backgroundColor: AppColors.brandPrimaryLight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total selectionne',
                    style: AppTextStyles.labelLarge,
                  ),
                ),
                Text(
                  MoneyFormatter.format(state.selectedTotal),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BadWalletPrimaryButton(
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            onPressed: state.selectedReferences.isEmpty ? null : onContinue,
          ),
        ],
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
      padding: const EdgeInsets.all(24),
      children: [
        _ScreenHeader(title: 'Confirmation', onBack: onBack),
        const SizedBox(height: 20),
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
        const SizedBox(height: 16),
        ...state.bills
            .where((bill) => state.selectedReferences.contains(bill.reference))
            .map(
              (bill) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BadWalletCard(
                  padding: const EdgeInsets.all(14),
                  child: _SummaryRow(
                    label: bill.reference,
                    value: MoneyFormatter.format(bill.amount),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedResultIcon(isSuccess: isSuccess),
              const SizedBox(height: 18),
              Text(
                isSuccess ? 'Paiement reussi' : 'Paiement echoue',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              if (result != null) ...[
                const SizedBox(height: 16),
                Text(
                  MoneyFormatter.format(result!.totalAmount),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(24),
      children: const [
        BadWalletSkeletonBox(width: 180, height: 34),
        SizedBox(height: 18),
        BadWalletSkeletonBox(width: double.infinity, height: 92),
        SizedBox(height: 16),
        BadWalletSkeletonBox(width: double.infinity, height: 78),
        SizedBox(height: 10),
        BadWalletSkeletonBox(width: double.infinity, height: 78),
        SizedBox(height: 10),
        BadWalletSkeletonBox(width: double.infinity, height: 78),
      ],
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.title, required this.onBack});

  final String title;
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
        Text(title, style: AppTextStyles.headlineLarge),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          const SizedBox(width: 16),
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
