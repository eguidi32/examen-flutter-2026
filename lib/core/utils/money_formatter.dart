import 'package:intl/intl.dart';

class MoneyFormatter {
  const MoneyFormatter._();

  static final NumberFormat _amountFormatter = NumberFormat.decimalPattern(
    'fr_FR',
  );

  static String format(num amount, {String currency = 'XOF'}) {
    final roundedAmount = amount.round();
    final suffix = currency == 'XOF' ? 'XOF' : currency;
    return '${_amountFormatter.format(roundedAmount)} $suffix';
  }

  static String signedFormat(
    num amount, {
    required bool isCredit,
    String currency = 'XOF',
  }) {
    final sign = isCredit ? '+' : '-';
    return '$sign ${format(amount, currency: currency)}';
  }
}
