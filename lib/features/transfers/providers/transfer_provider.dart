import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/phone_number_formatter.dart';
import '../data/transfer_receipt.dart';
import '../data/transfer_repository.dart';

class TransferDraft {
  const TransferDraft({
    this.receiverPhone = '',
    this.amountDigits = '',
    this.receiverError,
    this.amountError,
  });

  final String receiverPhone;
  final String amountDigits;
  final String? receiverError;
  final String? amountError;

  double get amount => double.tryParse(amountDigits) ?? 0;

  bool get isEmpty => receiverPhone.isEmpty && amountDigits.isEmpty;

  TransferDraft copyWith({
    String? receiverPhone,
    String? amountDigits,
    String? receiverError,
    String? amountError,
    bool clearReceiverError = false,
    bool clearAmountError = false,
  }) {
    return TransferDraft(
      receiverPhone: receiverPhone ?? this.receiverPhone,
      amountDigits: amountDigits ?? this.amountDigits,
      receiverError: clearReceiverError
          ? null
          : receiverError ?? this.receiverError,
      amountError: clearAmountError ? null : amountError ?? this.amountError,
    );
  }
}

sealed class TransferState {
  const TransferState();
}

class TransferEmpty extends TransferState {
  const TransferEmpty();
}

class TransferLoaded extends TransferState {
  const TransferLoaded();
}

class TransferLoading extends TransferState {
  const TransferLoading();
}

class TransferSuccess extends TransferState {
  const TransferSuccess({required this.receipt});

  final TransferReceipt receipt;
}

class TransferError extends TransferState {
  const TransferError({required this.message});

  final String message;
}

class TransferProvider extends ChangeNotifier {
  TransferProvider({required this.repository});

  final TransferRepository repository;

  TransferState _state = const TransferEmpty();
  TransferDraft _draft = const TransferDraft();

  TransferState get state => _state;

  TransferDraft get draft => _draft;

  void updateReceiver(String value) {
    _draft = _draft.copyWith(receiverPhone: value, clearReceiverError: true);
    _syncEditingState();
  }

  void appendAmountDigit(String digit) {
    if (_draft.amountDigits.length >= 9) {
      return;
    }

    final nextDigits = _draft.amountDigits == '0'
        ? digit
        : '${_draft.amountDigits}$digit';
    _draft = _draft.copyWith(amountDigits: nextDigits, clearAmountError: true);
    _syncEditingState();
  }

  void deleteAmountDigit() {
    if (_draft.amountDigits.isEmpty) {
      return;
    }

    _draft = _draft.copyWith(
      amountDigits: _draft.amountDigits.substring(
        0,
        _draft.amountDigits.length - 1,
      ),
      clearAmountError: true,
    );
    _syncEditingState();
  }

  void clearAmount() {
    _draft = _draft.copyWith(amountDigits: '', clearAmountError: true);
    _syncEditingState();
  }

  bool validateDraft(String senderPhone) {
    final normalizedReceiver = PhoneNumberFormatter.normalize(
      _draft.receiverPhone,
    );
    String? receiverError;
    String? amountError;

    if (!PhoneNumberFormatter.isValid(normalizedReceiver)) {
      receiverError = PhoneNumberFormatter.validationMessage;
    } else if (normalizedReceiver == senderPhone) {
      receiverError = 'Le destinataire doit etre different de vous.';
    }

    if (_draft.amount <= 0) {
      amountError = 'Saisissez un montant superieur a 0.';
    }

    _draft = _draft.copyWith(
      receiverPhone: normalizedReceiver,
      receiverError: receiverError,
      amountError: amountError,
      clearReceiverError: receiverError == null,
      clearAmountError: amountError == null,
    );
    _syncEditingState();
    return receiverError == null && amountError == null;
  }

  Future<TransferReceipt?> submit(String senderPhone) async {
    if (!validateDraft(senderPhone)) {
      return null;
    }

    _setState(const TransferLoading());
    try {
      final receipt = await repository.transfer(
        senderPhone: senderPhone,
        receiverPhone: _draft.receiverPhone,
        amount: _draft.amount,
      );
      _setState(TransferSuccess(receipt: receipt));
      return receipt;
    } on ApiException catch (exception) {
      _setState(TransferError(message: exception.message));
      return null;
    } catch (_) {
      _setState(const TransferError(message: AppStrings.genericError));
      return null;
    }
  }

  void resetAfterResult() {
    _draft = const TransferDraft();
    _setState(const TransferEmpty());
  }

  void _syncEditingState() {
    _setState(_draft.isEmpty ? const TransferEmpty() : const TransferLoaded());
  }

  void _setState(TransferState state) {
    _state = state;
    notifyListeners();
  }
}
