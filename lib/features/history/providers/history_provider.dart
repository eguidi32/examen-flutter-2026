import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/wallet_transaction.dart';
import '../../../core/network/api_client.dart';
import '../data/history_repository.dart';

enum HistoryFilter { all, credits, debits }

sealed class HistoryState {
  const HistoryState();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded({
    required this.allTransactions,
    required this.transactions,
    required this.query,
    required this.filter,
  });

  final List<WalletTransaction> allTransactions;
  final List<WalletTransaction> transactions;
  final String query;
  final HistoryFilter filter;
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
  List<WalletTransaction> _allTransactions = const [];
  String _query = '';
  HistoryFilter _filter = HistoryFilter.all;

  HistoryState get state => _state;

  Future<void> load() async {
    _setState(const HistoryLoading());
    try {
      _allTransactions = await repository.fetchTransactions(phoneNumber);
      _emitLoaded();
    } on ApiException catch (exception) {
      _setState(HistoryError(message: exception.message));
    } catch (_) {
      _setState(const HistoryError(message: AppStrings.genericError));
    }
  }

  void updateQuery(String value) {
    _query = value;
    _emitLoaded();
  }

  void updateFilter(HistoryFilter filter) {
    _filter = filter;
    _emitLoaded();
  }

  void _emitLoaded() {
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleTransactions = _allTransactions.where((transaction) {
      final isCredit = transaction.isCreditFor(phoneNumber);
      final matchesFilter = switch (_filter) {
        HistoryFilter.all => true,
        HistoryFilter.credits => isCredit,
        HistoryFilter.debits => !isCredit,
      };

      if (!matchesFilter) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final searchable = [
        transaction.titleFor(phoneNumber),
        transaction.subtitleFor(phoneNumber),
        transaction.reference,
        transaction.amount.toStringAsFixed(0),
      ].join(' ').toLowerCase();

      return searchable.contains(normalizedQuery);
    }).toList();

    _setState(
      HistoryLoaded(
        allTransactions: _allTransactions,
        transactions: visibleTransactions,
        query: _query,
        filter: _filter,
      ),
    );
  }

  void _setState(HistoryState state) {
    _state = state;
    notifyListeners();
  }
}
