import '../../../core/models/wallet_transaction.dart';
import 'wallet_balance.dart';

class MockDashboardData {
  const MockDashboardData._();

  static WalletBalance balance(String phoneNumber) {
    return WalletBalance(
      phoneNumber: phoneNumber,
      code: 'BW-2026-001',
      balance: 124500,
      currency: 'XOF',
    );
  }

  static List<WalletTransaction> transactions(String phoneNumber) {
    final now = DateTime.now();
    return [
      _transaction(
        id: 1,
        walletId: 1,
        amount: 25000,
        type: 'TRANSFER',
        reference: 'Paiement reçu',
        message: 'Reçu de A. Konan',
        createdAt: now.copyWith(hour: 9, minute: 15),
        senderPhone: '+221770000011',
        receiverPhone: phoneNumber,
      ),
      _transaction(
        id: 2,
        walletId: 1,
        amount: 10000,
        type: 'TRANSFER',
        reference: "Transfert d'argent",
        message: 'Envoyé à M. Traoré',
        createdAt: now.copyWith(hour: 8, minute: 45),
        senderPhone: phoneNumber,
        receiverPhone: '+221770000012',
      ),
      _transaction(
        id: 3,
        walletId: 1,
        amount: 15500,
        type: 'TRANSFER',
        reference: 'Remboursement',
        message: 'Reçu de S. Coulibaly',
        createdAt: now
            .subtract(const Duration(days: 1))
            .copyWith(hour: 18, minute: 30),
        senderPhone: '+221770000013',
        receiverPhone: phoneNumber,
      ),
      _transaction(
        id: 4,
        walletId: 1,
        amount: 2000,
        type: 'BILL_PAYMENT',
        reference: 'Achat de crédit',
        message: 'Paiement à Orange',
        createdAt: now
            .subtract(const Duration(days: 1))
            .copyWith(hour: 17, minute: 12),
        senderPhone: phoneNumber,
      ),
      _transaction(
        id: 5,
        walletId: 1,
        amount: 8750,
        type: 'WITHDRAW',
        reference: 'Achat',
        message: 'Paiement à Super U',
        createdAt: now
            .subtract(const Duration(days: 1))
            .copyWith(hour: 14, minute: 5),
        senderPhone: phoneNumber,
      ),
      _transaction(
        id: 6,
        walletId: 1,
        amount: 30000,
        type: 'TRANSFER',
        reference: 'Paiement reçu',
        message: 'Reçu de Y. Diarra',
        createdAt: now
            .subtract(const Duration(days: 12))
            .copyWith(hour: 11, minute: 20),
        senderPhone: '+221770000014',
        receiverPhone: phoneNumber,
      ),
      _transaction(
        id: 7,
        walletId: 1,
        amount: 5000,
        type: 'TRANSFER',
        reference: "Transfert d'argent",
        message: 'Envoyé à D. Koffi',
        createdAt: now
            .subtract(const Duration(days: 13))
            .copyWith(hour: 16, minute: 40),
        senderPhone: phoneNumber,
        receiverPhone: '+221770000015',
      ),
      _transaction(
        id: 8,
        walletId: 1,
        amount: 12000,
        type: 'TRANSFER',
        reference: 'Remboursement',
        message: "Reçu de C. N'guessan",
        createdAt: now
            .subtract(const Duration(days: 14))
            .copyWith(hour: 10, minute: 5),
        senderPhone: '+221770000016',
        receiverPhone: phoneNumber,
      ),
      _transaction(
        id: 9,
        walletId: 1,
        amount: 3000,
        type: 'BILL_PAYMENT',
        reference: 'Abonnement',
        message: 'Paiement à Canal+',
        createdAt: now
            .subtract(const Duration(days: 15))
            .copyWith(hour: 19, minute: 30),
        senderPhone: phoneNumber,
      ),
      _transaction(
        id: 10,
        walletId: 1,
        amount: 4250,
        type: 'WITHDRAW',
        reference: 'Achat',
        message: 'Paiement à Pharmacie Santé',
        createdAt: now
            .subtract(const Duration(days: 16))
            .copyWith(hour: 15, minute: 10),
        senderPhone: phoneNumber,
      ),
    ];
  }

  static WalletTransaction _transaction({
    required int id,
    required int walletId,
    required double amount,
    required String type,
    required String reference,
    required String message,
    required DateTime createdAt,
    String? senderPhone,
    String? receiverPhone,
  }) {
    return WalletTransaction(
      id: id,
      walletId: walletId,
      amount: amount,
      paymentMethod: 'WALLET',
      type: type,
      status: 'SUCCESS',
      reference: reference,
      message: message,
      createdAt: createdAt,
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
    );
  }
}
