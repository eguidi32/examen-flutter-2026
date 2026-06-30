import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../data/transfer_repository.dart';
import '../providers/transfer_provider.dart';
import 'widgets/amount_keypad.dart';
import 'widgets/receiver_avatar.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({
    required this.phoneNumber,
    required this.availableBalance,
    super.key,
    this.currency = 'XOF',
    this.repository,
    this.embedded = false,
    this.onExit,
    this.onCompleted,
  });

  final String phoneNumber;
  final double availableBalance;
  final String currency;
  final TransferRepository? repository;
  final bool embedded;
  final VoidCallback? onExit;
  final ValueChanged<bool>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          TransferProvider(repository: repository ?? ApiTransferRepository()),
      child: _TransferForm(
        phoneNumber: phoneNumber,
        availableBalance: availableBalance,
        currency: currency,
        embedded: embedded,
        onExit: onExit,
        onCompleted: onCompleted,
      ),
    );
  }
}

class _TransferForm extends StatefulWidget {
  const _TransferForm({
    required this.phoneNumber,
    required this.availableBalance,
    required this.currency,
    required this.embedded,
    this.onExit,
    this.onCompleted,
  });

  final String phoneNumber;
  final double availableBalance;
  final String currency;
  final bool embedded;
  final VoidCallback? onExit;
  final ValueChanged<bool>? onCompleted;

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  static const double _transferFee = 100;

  late final TextEditingController _receiverController;

  @override
  void initState() {
    super.initState();
    _receiverController = TextEditingController();
  }

  @override
  void dispose() {
    _receiverController.dispose();
    super.dispose();
  }

  void _exit() {
    if (widget.onExit != null) {
      widget.onExit!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<TransferProvider>();
    if (!provider.validateDraft(widget.phoneNumber)) {
      return;
    }

    _receiverController.text = provider.draft.receiverPhone;
    final amount = provider.draft.amount;
    final total = amount + _transferFee;
    if (total > widget.availableBalance) {
      provider.setDraftError(
        amountError: 'Solde insuffisant pour couvrir le montant et les frais.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer le transfert'),
          content: Text(
            'Envoyer ${MoneyFormatter.format(amount, currency: widget.currency)} '
            'vers ${provider.draft.receiverPhone} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    HapticFeedback.mediumImpact();
    final receipt = await provider.submit(widget.phoneNumber);
    if (!mounted || receipt == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfert envoyé avec succès.')),
    );
    widget.onCompleted?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final draft = provider.draft;
    final amount = draft.amount;
    final fee = amount > 0 ? _transferFee : 0.0;
    final total = amount + fee;
    final isLoading = provider.state is TransferLoading;
    final isOverBalance = total > widget.availableBalance && amount > 0;
    final canSubmit = !draft.isEmpty && !isLoading && !isOverBalance;
    final errorMessage = provider.state is TransferError
        ? (provider.state as TransferError).message
        : null;

    final content = ListView(
      padding: AppInsets.screen.copyWith(bottom: AppSpacing.xxl),
      children: [
        BadWalletHeader(
          title: 'Transférer',
          onBack: _exit,
          trailing: BadWalletIconBadge(
            icon: Icons.help_outline_rounded,
            color: AppColors.ink,
            backgroundColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Destinataire', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        BadWalletCard(
          padding: AppInsets.compactCard,
          child: Row(
            children: [
              ReceiverAvatar(phoneNumber: draft.receiverPhone),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BadWalletTextField(
                  label: 'Numéro téléphone',
                  controller: _receiverController,
                  hintText: '+221 77 000 00 02',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onChanged: provider.updateReceiver,
                ),
              ),
            ],
          ),
        ),
        _InlineError(message: draft.receiverError),
        const SizedBox(height: AppSpacing.md),
        Text('Montant', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        _AmountCard(
          amount: amount,
          currency: widget.currency,
          onClear: provider.clearAmount,
        ),
        _InlineError(
          message: isOverBalance
              ? 'Le total dépasse votre solde disponible.'
              : draft.amountError,
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.brandPrimaryLight,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Solde disponible : ${MoneyFormatter.format(widget.availableBalance, currency: widget.currency)}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _TransferSummaryCard(
          fee: fee,
          amount: amount,
          total: total,
          currency: widget.currency,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          _ErrorBanner(message: errorMessage),
        ],
        const SizedBox(height: AppSpacing.lg),
        AmountKeypad(
          onDigitPressed: provider.appendAmountDigit,
          onBackspacePressed: provider.deleteAmountDigit,
        ),
        const SizedBox(height: AppSpacing.lg),
        BadWalletPrimaryButton(
          label: 'Envoyer',
          icon: Icons.send_rounded,
          isLoading: isLoading,
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(body: SafeArea(child: content));
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.amount,
    required this.currency,
    required this.onClear,
  });

  final double amount;
  final String currency;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return BadWalletCard(
      backgroundColor: AppColors.brandPrimary,
      gradient: AppColors.balanceGradient,
      borderColor: AppColors.brandPrimary,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.normal,
                  child: Text(
                    amount > 0
                        ? MoneyFormatter.format(amount, currency: currency)
                        : '0 $currency',
                    key: ValueKey(amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  amount > 0 ? 'Montant à envoyer' : 'Saisissez un montant',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onClear,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white.withValues(alpha: 0.18),
              foregroundColor: AppColors.white,
            ),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _TransferSummaryCard extends StatelessWidget {
  const _TransferSummaryCard({
    required this.fee,
    required this.amount,
    required this.total,
    required this.currency,
  });

  final double fee;
  final double amount;
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return BadWalletCard(
      child: Column(
        children: [
          _SummaryRow(
            label: 'Frais de transfert',
            value: MoneyFormatter.format(fee, currency: currency),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Montant à envoyer',
            value: MoneyFormatter.format(amount, currency: currency),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          _SummaryRow(
            label: 'Total à débiter',
            value: MoneyFormatter.format(total, currency: currency),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? AppTextStyles.labelLarge.copyWith(color: AppColors.brandPrimary)
        : AppTextStyles.bodyMedium.copyWith(color: AppColors.ink);

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          textAlign: TextAlign.right,
          style: style.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      child: message == null
          ? const SizedBox(height: AppSpacing.sm)
          : Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
    );
  }
}
