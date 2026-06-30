import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../data/transfer_repository.dart';
import '../providers/transfer_provider.dart';
import 'widgets/amount_keypad.dart';
import 'widgets/receiver_avatar.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({required this.phoneNumber, super.key, this.repository});

  final String phoneNumber;
  final TransferRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          TransferProvider(repository: repository ?? ApiTransferRepository()),
      child: _TransferFlow(phoneNumber: phoneNumber),
    );
  }
}

enum _TransferStep { form, confirmation, result }

class _TransferFlow extends StatefulWidget {
  const _TransferFlow({required this.phoneNumber});

  final String phoneNumber;

  @override
  State<_TransferFlow> createState() => _TransferFlowState();
}

class _TransferFlowState extends State<_TransferFlow> {
  late final TextEditingController _receiverController;
  _TransferStep _step = _TransferStep.form;
  bool _resultSuccess = false;
  String _resultMessage = '';

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

  void _goToConfirmation() {
    FocusScope.of(context).unfocus();
    final provider = context.read<TransferProvider>();
    if (!provider.validateDraft(widget.phoneNumber)) {
      return;
    }
    _receiverController.text = provider.draft.receiverPhone;
    setState(() => _step = _TransferStep.confirmation);
  }

  Future<void> _confirmTransfer() async {
    HapticFeedback.mediumImpact();
    final provider = context.read<TransferProvider>();
    final receipt = await provider.submit(widget.phoneNumber);
    final state = provider.state;

    if (receipt != null && state is TransferSuccess) {
      setState(() {
        _resultSuccess = true;
        _resultMessage = 'Transfert envoye a ${receipt.receiverPhone}.';
        _step = _TransferStep.result;
      });
      return;
    }

    if (state is TransferError) {
      setState(() {
        _resultSuccess = false;
        _resultMessage = state.message;
        _step = _TransferStep.result;
      });
    }
  }

  void _retry() {
    setState(() => _step = _TransferStep.form);
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
            _TransferStep.form => _TransferForm(
              key: const ValueKey('transfer-form'),
              controller: _receiverController,
              onContinue: _goToConfirmation,
            ),
            _TransferStep.confirmation => _TransferConfirmation(
              key: const ValueKey('transfer-confirmation'),
              onBack: () => setState(() => _step = _TransferStep.form),
              onConfirm: _confirmTransfer,
            ),
            _TransferStep.result => _TransferResult(
              key: const ValueKey('transfer-result'),
              isSuccess: _resultSuccess,
              message: _resultMessage,
              onDone: _closeResult,
              onRetry: _retry,
            ),
          },
        ),
      ),
    );
  }
}

class _TransferForm extends StatelessWidget {
  const _TransferForm({
    required this.controller,
    required this.onContinue,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final draft = provider.draft;
    final amount = draft.amountDigits.isEmpty ? 0 : draft.amount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScreenHeader(
                title: 'Transferer',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 20),
              BadWalletCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ReceiverAvatar(phoneNumber: draft.receiverPhone),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BadWalletTextField(
                            label: 'Destinataire',
                            controller: controller,
                            hintText: '+221 77 000 00 02',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.phone_rounded,
                            onChanged: provider.updateReceiver,
                          ),
                        ),
                      ],
                    ),
                    _InlineError(message: draft.receiverError),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BadWalletCard(
                child: Column(
                  children: [
                    Text('Montant', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        MoneyFormatter.format(amount),
                        key: ValueKey(draft.amountDigits),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: amount > 0 ? AppColors.ink : AppColors.inkSoft,
                        ),
                      ),
                    ),
                    _InlineError(message: draft.amountError),
                    const SizedBox(height: 18),
                    AmountKeypad(
                      onDigitPressed: provider.appendAmountDigit,
                      onBackspacePressed: provider.deleteAmountDigit,
                      onClearPressed: provider.clearAmount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BadWalletPrimaryButton(
                label: 'Continuer',
                icon: Icons.arrow_forward_rounded,
                onPressed: draft.isEmpty ? null : onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferConfirmation extends StatelessWidget {
  const _TransferConfirmation({
    required this.onBack,
    required this.onConfirm,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final draft = provider.draft;
    final isLoading = provider.state is TransferLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScreenHeader(title: 'Confirmation', onBack: onBack),
              const SizedBox(height: 20),
              BadWalletCard(
                child: Column(
                  children: [
                    ReceiverAvatar(phoneNumber: draft.receiverPhone, size: 64),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      label: 'Destinataire',
                      value: draft.receiverPhone,
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: 'Montant',
                      value: MoneyFormatter.format(draft.amount),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BadWalletPrimaryButton(
                label: 'Confirmer le transfert',
                icon: Icons.verified_rounded,
                isLoading: isLoading,
                onPressed: isLoading ? null : onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferResult extends StatelessWidget {
  const _TransferResult({
    required this.isSuccess,
    required this.message,
    required this.onDone,
    required this.onRetry,
    super.key,
  });

  final bool isSuccess;
  final String message;
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
                isSuccess ? 'Transfert reussi' : 'Transfert echoue',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: message == null
          ? const SizedBox(height: 12)
          : Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(top: 10),
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
