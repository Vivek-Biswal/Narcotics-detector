import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toDisplayString() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String toDateOnly() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toTimeOnly() {
    return DateFormat('HH:mm').format(this);
  }

  String toIso() => toIso8601String();
}

extension StringExtensions on String {
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  String get initials {
    final words = trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return isEmpty ? '' : this[0].toUpperCase();
  }
}

extension DoubleExtensions on double {
  String toGpsString(int decimals) => toStringAsFixed(decimals);
}
