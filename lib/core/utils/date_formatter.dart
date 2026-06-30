import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static final DateFormat _dayFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');

  static String groupLabel(DateTime? value) {
    if (value == null) {
      return 'Date inconnue';
    }

    final date = DateTime(value.year, value.month, value.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return "Aujourd'hui";
    }
    if (date == yesterday) {
      return 'Hier';
    }
    return _dayFormatter.format(value);
  }

  static String time(DateTime? value) {
    if (value == null) {
      return '--:--';
    }
    return _timeFormatter.format(value);
  }

  static String day(DateTime? value) {
    if (value == null) {
      return 'Date inconnue';
    }
    return _dayFormatter.format(value);
  }
}
