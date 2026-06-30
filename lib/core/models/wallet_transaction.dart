class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.paymentMethod,
    required this.type,
    required this.status,
    required this.reference,
    this.fees,
    this.total,
    this.balance,
    this.createdAt,
    this.message,
    this.senderPhone,
    this.receiverPhone,
  });

  final int id;
  final int walletId;
  final double amount;
  final double? fees;
  final double? total;
  final double? balance;
  final String paymentMethod;
  final String type;
  final String status;
  final String reference;
  final DateTime? createdAt;
  final String? message;
  final String? senderPhone;
  final String? receiverPhone;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _asInt(json['id']),
      walletId: _asInt(json['walletId']),
      amount: _asDouble(json['amount']),
      fees: _asNullableDouble(json['fees']),
      total: _asNullableDouble(json['total']),
      balance: _asNullableDouble(json['balance']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      createdAt: _asDate(json['createdAt']),
      message: json['message']?.toString(),
      senderPhone: json['senderPhone']?.toString(),
      receiverPhone: json['receiverPhone']?.toString(),
    );
  }

  bool isCreditFor(String phoneNumber) {
    final normalizedPhone = phoneNumber.trim();

    return switch (type) {
      'DEPOSIT' || 'SEED' => true,
      'WITHDRAW' || 'BILL_PAYMENT' => false,
      'TRANSFER' when receiverPhone == normalizedPhone => true,
      'TRANSFER' when senderPhone == normalizedPhone => false,
      'TRANSFER' => false,
      _ => false,
    };
  }

  String titleFor(String phoneNumber) {
    return switch (type) {
      'DEPOSIT' || 'SEED' => 'Depot',
      'WITHDRAW' => 'Retrait',
      'BILL_PAYMENT' => 'Paiement facture',
      'TRANSFER' when isCreditFor(phoneNumber) => 'Transfert recu',
      'TRANSFER' => 'Transfert envoye',
      _ => 'Transaction',
    };
  }

  String subtitleFor(String phoneNumber) {
    if (type == 'TRANSFER') {
      if (isCreditFor(phoneNumber) && senderPhone != null) {
        return 'Depuis $senderPhone';
      }
      if (!isCreditFor(phoneNumber) && receiverPhone != null) {
        return 'Vers $receiverPhone';
      }
    }

    if (reference.isNotEmpty) {
      return reference;
    }
    return status;
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(Object? value) {
    return _asNullableDouble(value) ?? 0;
  }

  static double? _asNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static DateTime? _asDate(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
