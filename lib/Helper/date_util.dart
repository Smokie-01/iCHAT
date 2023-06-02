import 'package:flutter/material.dart';

class MyDateUtil {
  //for getting formated time from milliseconds Epoch;
  static String getTimeInFormat(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);

    // this if statement checks , weatther the sent year, day , month is same as today;
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    return now.year == sent.year
        ? "${formattedTime}  ${sent.day}" " ${_getMonth(sent)}" " ${sent.year}"
        : "${formattedTime}  ${sent.day}" " ${_getMonth(sent)}";
  }

  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear
        ? "${sent.day}" " ${_getMonth(sent)}" " ${sent.year}"
        : "${sent.day}" " ${_getMonth(sent)}";
  }

  static String getLastACtiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    if (i == -1) return 'Last Seen Not Available ';
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);

    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return "Last Seen toaday at $formattedTime ";
    }
    //  if the diffrece bettwen last active is of 1 day Today
    if ((now.difference(time).inHours / 24).round() == 1) {
      return "Last Seen Yesterday at $formattedTime";
    }
    String month = _getMonth(time);
    return " Last Seen on ${time.day} $month on $formattedTime";
  }

  static _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
  }
}
