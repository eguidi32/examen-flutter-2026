import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/wallet_transaction.dart';
import '../../../core/network/api_client.dart';
import '../data/history_repository.dart';

sealed class HistoryState {
  const HistoryState();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded({required this.transactions});

  final List<WalletTransaction> transactions;
}

class HistoryError extends HistoryState {
  const HistoryError({required this.message});

  final String message;
}

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({required this.phoneNumber, required this.repository});

  final String phoneNumber;
  final HistoryRepository repository;

  HistoryState _state = const HistoryLoading();

  HistoryState get state => _state;

  Future<void> load() async {
    _setState(const HistoryLoading());
    try {
      final transactions = await repository.fetchTransactions(phoneNumber);
      _setState(HistoryLoaded(transactions: transactions));
    } on ApiException catch (exception) {
      _setState(HistoryError(message: exception.message));
    } catch (_) {
      _setState(const HistoryError(message: AppStrings.genericError));
    }
  }

  void _setState(HistoryState state) {
    _state = state;
    notifyListeners();
  }
}
