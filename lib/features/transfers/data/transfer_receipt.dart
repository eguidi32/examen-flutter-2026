import '../../../core/models/wallet_transaction.dart';

class TransferReceipt {
  const TransferReceipt({
    required this.transaction,
    required this.senderPhone,
    required this.receiverPhone,
    required this.amount,
  });

  final WalletTransaction transaction;
  final String senderPhone;
  final String receiverPhone;
  final double amount;

  factory TransferReceipt.fromJson({
    required Map<String, dynamic> json,
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) {
    return TransferReceipt(
      transaction: WalletTransaction.fromJson(json),
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
      amount: amount,
    );
  }
}
