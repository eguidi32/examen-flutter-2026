class Bill {
  const Bill({
    required this.id,
    required this.reference,
    required this.walletCode,
    required this.serviceName,
    required this.amount,
    required this.status,
    this.dueDate,
  });

  final int id;
  final String reference;
  final String walletCode;
  final String serviceName;
  final double amount;
  final String status;
  final DateTime? dueDate;

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: _asInt(json['id']),
      reference: json['reference']?.toString() ?? '',
      walletCode: json['walletCode']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      status: json['status']?.toString() ?? '',
      dueDate: _asDate(json['dueDate']),
    );
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
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDate(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
