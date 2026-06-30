import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../data/bill.dart';
import '../data/bill_payment_result.dart';
import '../data/bill_service.dart';
import '../data/bills_repository.dart';

sealed class BillsState {
  const BillsState();
}

class BillsLoading extends BillsState {
  const BillsLoading();
}

class BillsLoaded extends BillsState {
  const BillsLoaded({
    required this.service,
    required this.bills,
    this.selectedReferences = const {},
    this.isPaying = false,
  });

  final BillService service;
  final List<Bill> bills;
  final Set<String> selectedReferences;
  final bool isPaying;

  double get selectedTotal {
    return bills
        .where((bill) => selectedReferences.contains(bill.reference))
        .fold<double>(0, (total, bill) => total + bill.amount);
  }

  List<String> get selectedReferencesList => selectedReferences.toList();

  bool get hasSelection => selectedReferences.isNotEmpty;

  bool get allSelected =>
      bills.isNotEmpty && selectedReferences.length == bills.length;

  BillsLoaded copyWith({
    BillService? service,
    List<Bill>? bills,
    Set<String>? selectedReferences,
    bool? isPaying,
  }) {
    return BillsLoaded(
      service: service ?? this.service,
      bills: bills ?? this.bills,
      selectedReferences: selectedReferences ?? this.selectedReferences,
      isPaying: isPaying ?? this.isPaying,
    );
  }
}

class BillsError extends BillsState {
  const BillsError({required this.message});

  final String message;
}

class BillsProvider extends ChangeNotifier {
  BillsProvider({
    required this.phoneNumber,
    required this.walletCode,
    required this.repository,
  });

  final String phoneNumber;
  final String walletCode;
  final BillsRepository repository;

  BillsState _state = const BillsLoading();

  BillsState get state => _state;

  Future<void> load({BillService service = BillService.ism}) async {
    _setState(const BillsLoading());
    try {
      final bills = await repository.fetchCurrentBills(
        walletCode: walletCode,
        service: service,
      );
      _setState(BillsLoaded(service: service, bills: bills));
    } on ApiException catch (exception) {
      _setState(BillsError(message: exception.message));
    } catch (_) {
      _setState(const BillsError(message: AppStrings.genericError));
    }
  }

  Future<void> selectService(BillService service) {
    return load(service: service);
  }

  void toggleBill(String reference) {
    final current = _state;
    if (current is! BillsLoaded || current.isPaying) {
      return;
    }

    final nextSelection = Set<String>.from(current.selectedReferences);
    if (nextSelection.contains(reference)) {
      nextSelection.remove(reference);
    } else {
      nextSelection.add(reference);
    }

    _setState(current.copyWith(selectedReferences: nextSelection));
  }

  void toggleSelectAll() {
    final current = _state;
    if (current is! BillsLoaded || current.isPaying) {
      return;
    }

    final nextSelection = current.allSelected
        ? <String>{}
        : current.bills.map((bill) => bill.reference).toSet();
    _setState(current.copyWith(selectedReferences: nextSelection));
  }

  Future<BillPaymentResult?> paySelected() async {
    final current = _state;
    if (current is! BillsLoaded || current.selectedReferences.isEmpty) {
      return null;
    }

    _setState(current.copyWith(isPaying: true));
    try {
      final result = await repository.payBills(
        phoneNumber: phoneNumber,
        walletCode: walletCode,
        service: current.service,
        references: current.selectedReferencesList,
        fallbackTotal: current.selectedTotal,
      );
      _setState(current.copyWith(isPaying: false));
      return result;
    } on ApiException {
      _setState(current.copyWith(isPaying: false));
      rethrow;
    } catch (_) {
      _setState(current.copyWith(isPaying: false));
      throw const ApiException(message: AppStrings.genericError);
    }
  }

  void _setState(BillsState state) {
    _state = state;
    notifyListeners();
  }
}
