
import 'package:intl/intl.dart';

class DateTimeParser {
  static DateFormat englishDateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static DateFormat englishDateTimeFormatWithSec =
      DateFormat("yyyy-MM-dd HH:mm:ss");
  static DateFormat frenchDateTimeFormat = DateFormat("dd-MM-yyyy HH:mm");
  static DateFormat HHmmDateTimeFormat = DateFormat("HH:mm");

  /// Examples: kFontSize21-01-01T10:35 --> kFontSize21-01-01T11:00
  ///           kFontSize21-01-01T10:25 --> kFontSize21-01-01T10:00
  static DateTime roundDateTimeToHour(DateTime dateTime) {
    if (dateTime.minute >= 30) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour + 1, 0, 0, 0, 0);
    } else {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour, 0, 0, 0, 0);
    }
  }

  /// This method takes a DateTime object as input and returns a new DateTime
  /// object with the same year, month, day, hour, and minute as the input,
  /// but with seconds and milliseconds set to zero. Essentially, it rounds
  /// the input DateTime object down to the nearest minute.
  static DateTime truncateDateTimeToMinute(DateTime dateTime) {
    return DateTimeParser.englishDateTimeFormat
        .parse(DateTimeParser.englishDateTimeFormat.format(dateTime));
  }

  /// Method used to format the entered string duration
  /// to the duration TextField format, either HH:mm or
  /// dd:HH:mm. The method enables entering an int
  /// duration value instead of an HH:mm duration. For
  /// example, 2 or 24 instead of 02:00 or 24:00.
  ///
  /// If the removeMinusSign parm is false, entering -2
  /// converts the duration string to -2:00, which is
  /// useful in the Add dialog accepting adding a positive
  /// or negative duration.
  ///
  /// If dayHourMinuteFormat is true, the returned string
  /// duration for 2 is 00:02:00 or for 3:24 00:03:24.
  ///
  /// This method has been extracted from utils/utility.dart
  /// in circa_plan project in which the method is unit
  /// tested.
  static String formatStringDuration({
    required String durationStr,
    bool removeMinusSign = true,
    bool dayHourMinuteFormat = false,
  }) {
    if (removeMinusSign) {
      durationStr = durationStr.replaceAll(RegExp(r'[+\-]+'), '');
    } else {
      durationStr = durationStr.replaceAll(RegExp(r'[+]+'), '');
    }

    if (dayHourMinuteFormat) {
      // the case if used on TimeCalculator screen
      int? durationInt = int.tryParse(durationStr);

      if (durationInt != null) {
        if (durationInt < 0) {
          if (durationInt > -10) {
            durationStr = '-00:0${durationInt * -1}:00';
          } else {
            durationStr = '-00:${durationInt * -1}:00';
          }
        } else {
          if (durationInt < 10) {
            durationStr = '00:0$durationStr:00';
          } else {
            durationStr = '00:$durationStr:00';
          }
        }
      } else {
        RegExp re = RegExp(r"^\d+:\d{1}$");
        RegExpMatch? match = re.firstMatch(durationStr);
        if (match != null) {
          durationStr = '${match.group(0)}0';
        } else {
          if (!removeMinusSign) {
            RegExp re = RegExp(r"^-\d+:\d{1}$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = '${match.group(0)}0';
            }
          }
        }
      }

      RegExp re = RegExp(r"^\d{1}:\d+$");
      RegExpMatch? match = re.firstMatch(durationStr);

      if (match != null) {
        durationStr = '00:0${match.group(0)}';
      } else {
        RegExp re = RegExp(r"^\d{2}:\d+$");
        RegExpMatch? match = re.firstMatch(durationStr);
        if (match != null) {
          durationStr = '00:${match.group(0)}';
        } else {
          RegExp re = RegExp(r"^\d{1}:\d{2}:\d+$");
          RegExpMatch? match = re.firstMatch(durationStr);
          if (match != null) {
            durationStr = '0${match.group(0)}';
          } else {
            RegExp re = RegExp(r"^\d{2}:\d{2}:\d+$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = '${match.group(0)}';
            }
          }
        }
      }
    } else {
      int? durationInt = int.tryParse(durationStr);

      if (durationInt != null) {
        // the case if a one or two digits duration was entered ...
        durationStr = '$durationStr:00';
      } else {
        RegExp re = RegExp(r"^\d+:\d{1}$");
        RegExpMatch? match = re.firstMatch(durationStr);
        if (match != null) {
          durationStr = '${match.group(0)}0';
        } else {
          if (!removeMinusSign) {
            RegExp re = RegExp(r"^-\d+:\d{1}$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = '${match.group(0)}0';
            }
          } else {
            // the case when copying a 00:hh:mm time text field content to a
            // duration text field.
            RegExp re = RegExp(r"^00:\d{2}:\d{2}$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = match.group(0)!.replaceFirst('00:', '');
            }
          }
        }
      }
    }

    return durationStr;
  }

  /// If the input HH:mm time string is before now, the method
  /// returns a DateTime object with the same time but tomorrow.
  static DateTime? computeNextAlarmDateTime({
    required String formattedHhMmNextAlarmTimeStr,
  }) {
    int nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
    int nextAlarmMinutes;

    try {
      nextAlarmMinutes =
          int.parse(formattedHhMmNextAlarmTimeStr.split(':')[0]) * 60 +
              int.parse(formattedHhMmNextAlarmTimeStr.split(':')[1]);
    } catch (e) {
      return null;
    }

    if (nextAlarmMinutes <= nowMinutes) {
      return DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          int.parse(formattedHhMmNextAlarmTimeStr.split(':')[0]),
          int.parse(formattedHhMmNextAlarmTimeStr.split(':')[1]));
    }

    return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(formattedHhMmNextAlarmTimeStr.split(':')[0]),
        int.parse(formattedHhMmNextAlarmTimeStr.split(':')[1]));
  }

  /// This method takes a DateTime object as input and returns a
  /// string formatted as "HH:mm" or "dd-MM-yyyy HH:mm" depending
  /// on whether the input DateTime is after today midnight or not.
  static String formatDateTimeHHmmOrddMMyyyyHHmm({
    required DateTime dateTime,
  }) {
    DateTime now = DateTime.now();
    DateTime todayMidnight = DateTime(now.year, now.month, now.day);
    DateTime dateTimeMidnight =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    bool isNextAlarmDateAfterToday = dateTimeMidnight.isAfter(todayMidnight);

    if (isNextAlarmDateAfterToday) {
      return frenchDateTimeFormat.format(dateTime);
    } else {
      return HHmmDateTimeFormat.format(dateTime);
    }
  }

  /// This method takes a string as input and returns a DateTime
  /// object. The dateTimeStr can be formatted as "HH:mm" or
  /// "dd-MM-yyyy HH:mm".
  static DateTime? parseHHmmOrddMMyyyyHHmmDateTime({
    required String dateTimeStr,
  }) {
    DateTime? parsedDate;

    // Try parsing with the "HH:mm" format
    try {
      parsedDate = HHmmDateTimeFormat.parseStrict(dateTimeStr);
    } catch (e) {
      // If parsing with "HH:mm" fails, try "dd-MM-yyyy HH:mm"
      try {
        parsedDate = frenchDateTimeFormat.parseStrict(dateTimeStr);
      } catch (e) {
        // If parsing with both formats fails, return null
        parsedDate = null;
      }
    }

    return parsedDate;
  }
}
