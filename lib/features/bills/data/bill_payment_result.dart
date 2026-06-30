class BillPaymentResult {
  const BillPaymentResult({
    required this.phoneNumber,
    required this.walletCode,
    required this.serviceName,
    required this.factureReferences,
    required this.totalAmount,
    required this.balance,
    required this.status,
    required this.message,
  });

  final String phoneNumber;
  final String walletCode;
  final String serviceName;
  final List<String> factureReferences;
  final double totalAmount;
  final double balance;
  final String status;
  final String message;

  factory BillPaymentResult.fromJson(Map<String, dynamic> json) {
    return BillPaymentResult(
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      walletCode: json['walletCode']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      factureReferences: List<String>.from(json['factureReferences'] as List),
      totalAmount: _asDouble(json['totalAmount']),
      balance: _asDouble(json['balance']),
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
