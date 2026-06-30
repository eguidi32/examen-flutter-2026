import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/wallet_transaction.dart';
import '../../../core/network/api_client.dart';
import '../data/dashboard_repository.dart';
import '../data/wallet_balance.dart';

sealed class DashboardState {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.balance,
    required this.transactions,
    this.isRefreshing = false,
  });

  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final bool isRefreshing;

  DashboardLoaded copyWith({
    WalletBalance? balance,
    List<WalletTransaction>? transactions,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class DashboardError extends DashboardState {
  const DashboardError({required this.message});

  final String message;
}

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({required this.phoneNumber, required this.repository});

  final String phoneNumber;
  final DashboardRepository repository;

  DashboardState _state = const DashboardLoading();

  DashboardState get state => _state;

  Future<void> load() {
    return _load(showLoading: true);
  }

  Future<void> refresh() {
    return _load(showLoading: false);
  }

  Future<void> _load({required bool showLoading}) async {
    final previousState = _state;
    if (showLoading || previousState is! DashboardLoaded) {
      _setState(const DashboardLoading());
    } else {
      _setState(previousState.copyWith(isRefreshing: true));
    }

    try {
      final results = await Future.wait([
        repository.fetchBalance(phoneNumber),
        repository.fetchRecentTransactions(phoneNumber),
      ]);

      _setState(
        DashboardLoaded(
          balance: results[0] as WalletBalance,
          transactions: results[1] as List<WalletTransaction>,
        ),
      );
    } on ApiException catch (exception) {
      if (!showLoading && previousState is DashboardLoaded) {
        _setState(previousState.copyWith(isRefreshing: false));
        return;
      }
      _setState(DashboardError(message: exception.message));
    } catch (_) {
      if (!showLoading && previousState is DashboardLoaded) {
        _setState(previousState.copyWith(isRefreshing: false));
        return;
      }
      _setState(const DashboardError(message: AppStrings.genericError));
    }
  }

  void _setState(DashboardState state) {
    _state = state;
    notifyListeners();
  }
}
