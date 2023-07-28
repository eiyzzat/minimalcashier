import 'package:intl/intl.dart';

/* FormatIntegerText */
formatIntegerText(int amount) {
  NumberFormat intNumberFormat = NumberFormat('###,###,###');
  return intNumberFormat.format(amount).toString();
}
/* End FormatIntegerText */

/* FormatDoubleText */
formatDoubleText(double amount) {
  NumberFormat doubleNumberFormat = NumberFormat('###,###,###.00');

  if (amount == 0.0) {
    return '0.00';
  } else {
    return doubleNumberFormat.format(amount).toString();
  }
}
/* End FormatDoubleText */

/* FormatDateText */
formatDateText(int unixTime) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
  String dateText = DateFormat('dd/MM/yyyy').format(dateTime);

  return dateText;
}
/* End FormatDateText */

/* FormatTimeText */
formatTimeText(int unixTime) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
  String timeText = DateFormat().add_jm().format(dateTime);

  return timeText;
}
/* End FormatTimeText */

/* FormatStartEndTimeText */
formatStartEndTimeText(int unixTime, int duration) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
  DateTime endTime = dateTime.add(
    Duration(
      minutes: duration,
    ),
  );
  String startTimeText = DateFormat().add_jm().format(dateTime);
  String endTimeText = DateFormat().add_jm().format(endTime);

  return {'startTimeText': startTimeText, 'endTimeText': endTimeText};
}
/* FormatStartEndTimeText */