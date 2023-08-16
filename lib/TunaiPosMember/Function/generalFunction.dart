  import 'package:intl/intl.dart';

String formatAmount(dynamic amount) {
    if (amount == 0) {
      return '0.00';
    } else if (amount is int) {
      final format = NumberFormat('#,##0.00');
      return format.format(amount.toDouble());
    } else {
      final format = NumberFormat('#,##0.00');
      return format.format(amount);
    }
  }