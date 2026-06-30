class WalletBalance {
  const WalletBalance({
    required this.phoneNumber,
    required this.code,
    required this.balance,
    required this.currency,
  });

  final String phoneNumber;
  final String code;
  final double balance;
  final String currency;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      balance: _asDouble(json['balance']),
      currency: json['currency']?.toString() ?? 'XOF',
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
