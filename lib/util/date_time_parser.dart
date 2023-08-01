// adding method HHmm which returns the Duration formatted as HH:mm
import 'package:intl/intl.dart';

extension FormattedDayHourMinute on Duration {
  static final NumberFormat numberFormatTwoInt = NumberFormat('00');

  // ignore: non_constant_identifier_names
  
  /// Returns the Duration formatted as HH:mm.
  /// 
  /// This method is added to the Duration class by the extension
  /// FormattedDayHourMinute class located in date_time_parser.dart.
  String HHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';

    if (inMinutes < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  /// Returns the Duration formatted as dd:HH:mm
  /// 
  /// This method is added to the Duration class by the extension
  /// FormattedDayHourMinute class located in date_time_parser.dart.
  String ddHHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';
    int durationHour =
        Duration(minutes: (inMinutes - durationMinute)).inHours.remainder(24);
    int durationDay = Duration(hours: (inHours - durationHour)).inDays;

    if (inMinutes < 0) {
      minusStr = '-';
    }

    return "$minusStr${numberFormatTwoInt.format(durationDay.abs())}:${numberFormatTwoInt.format(durationHour.abs())}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }
}

class DateTimeParser {
  static final RegExp regExpYYYYDateTime =
      RegExp(r'^(\d+-\d+-\d{4})\s(\d+:\d{2})');
  static final RegExp regExpNoYearDateTime = RegExp(r'^(\d+-\d+)\s(\d+:\d{2})');
  static final RegExp regExpHHMMTime = RegExp(r'(^[-]?\d+:\d{2})');
  static final RegExp regExpHHAnyMMTime = RegExp(r'(^[-]?\d+:\d+)');
  static final RegExp regExpAllHHMMTime = RegExp(r'([-]?\d+:\d{2})');
  static final RegExp regExpDDHHMMTime = RegExp(r'(^[-]?\d+:\d+:\d{2})');
  static final RegExp regExpDDHHAnyMMTime = RegExp(r'(^[-]?\d+:\d+:\d+)');

  static DateFormat englishDateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static DateFormat frenchDateTimeFormat = DateFormat("dd-MM-yyyy HH:mm");
  static DateFormat HHmmDateTimeFormat = DateFormat("HH:mm");

  /// Parses the passed ddMMDateTimeStr formatted as dd-mm hh:mm or d-m h:mm
  static List<String?> parseDDMMDateTime(String ddMMDateTimrStr) {
    final RegExpMatch? match = regExpNoYearDateTime.firstMatch(ddMMDateTimrStr);
    final String? dayMonth = match?.group(1);
    final String? hourMinute = match?.group(2);

    return [dayMonth, hourMinute];
  }

  /// Parses the passed ddMMyyyyDateTimeStr formatted as dd-mm-yyyy hh:mm or d-m-yyyy h:mm
  static DateTime? parseDDMMYYYYDateTime(String ddMMyyyyDateTimrStr) {
    final RegExpMatch? match =
        regExpYYYYDateTime.firstMatch(ddMMyyyyDateTimrStr);
    final String? dayMonthYear = match?.group(1);
    final String? hourMinute = match?.group(2);

    DateTime? dateTime;

    if (dayMonthYear != null && hourMinute != null) {
      List<String> dayMonthYearStrLst = dayMonthYear.split('-');
      List<int?> dayMonthYearIntLst = dayMonthYearStrLst
          .map((element) => int.tryParse(element))
          .toList(growable: false);
      List<String> hourMinuteStrLst = hourMinute.split(':');
      List<int?> hourMinuteIntLst = hourMinuteStrLst
          .map((element) => int.tryParse(element))
          .toList(growable: false);

      if (!dayMonthYearIntLst.contains(null) &&
          !hourMinuteIntLst.contains(null)) {
        dateTime = DateTime(
          dayMonthYearIntLst[2] ?? 0, // year
          dayMonthYearIntLst[1] ?? 0, // month
          dayMonthYearIntLst[0] ?? 0, // day
          hourMinuteIntLst[0] ?? 0, // hour
          hourMinuteIntLst[1] ?? 0, // minute
        );
      }
    }

    return dateTime;
  }

  /// Parses the passed hourMinuteStr formatted as hh:mm or h:mm or -hh:mm or
  /// -h:mm and returns the hh:mm, h:mm, -hh:mm or -h:mm parsed String or null
  /// if the passed hourMinuteStr does not respect the hh:mm or h:mm or -hh:mm
  /// or -h:mm format, like 03:2 or 3:2 or 03-02 or 03:a2 or -03:2 or -3:2 or
  /// -03-02 or -03:a2 for example.
  static String? parseHHMMTimeStr(String hourMinuteStr) {
    final RegExpMatch? match = regExpHHMMTime.firstMatch(hourMinuteStr);
    final String? parsedHourMinuteStr = match?.group(1);

    return parsedHourMinuteStr;
  }

  /// Parses the passed hourMinuteStr formatted as hh:mm or h:mm or -hh:mm or
  /// -h:mm and returns the hh:mm, h:mm, -hh:mm or -h:mm parsed String or null
  /// if the passed hourMinuteStr does not respect the hh:mm or h:mm or -hh:mm
  /// or -h:mm format, like 03:2 or 3:2 or 03-02 or 03:a2 or -03:2 or -3:2 or
  /// -03-02 or -03:a2 for example.
  static String? parseHHAnyMMTimeStr(String hourMinuteStr) {
    final RegExpMatch? match = regExpHHAnyMMTime.firstMatch(hourMinuteStr);
    final String? parsedHourMinuteStr = match?.group(1);

    return parsedHourMinuteStr;
  }

  /// Parses the passed hourMinuteStr formatted as hh:mm or h:mm or -hh:mm or
  /// -h:mm and returns the hh:mm, h:mm, -hh:mm or -h:mm parsed String or null
  /// if the passed hourMinuteStr does not respect the hh:mm or h:mm or -hh:mm
  /// or -h:mm format, like 03:2 or 3:2 or 03-02 or 03:a2 or -03:2 or -3:2 or
  /// -03-02 or -03:a2 for example.
  static List<String> parseAllHHMMTimeStr(String multipleHHmmContainingStr) {
    return regExpAllHHMMTime
        .allMatches(multipleHHmmContainingStr)
        .map((m) => m.group(0))
        .whereType<String>()
        .toList();
  }

  /// Parses the passed int or hourMinuteStr formatted as h or hh or hh:mm or
  /// h:mm or -hh:mm or -h or -hh or -h:mm and returns the hh:mm, h:mm, -hh:mm
  /// or -h:mm parsed String or null if the passed hourMinuteStr does not
  /// respect the hh:mm or h:mm or -hh:mm or -h:mm format, like 03:2 or 3:2 or
  /// 03-02 or 03:a2 or -03:2 or -3:2 or -03-02 or -03:a2 for example.
  static List<String> parseAllIntOrHHMMTimeStr(
      String preferredDurationsItemValue) {
    RegExp regExp = RegExp(r'[ ,]+');
    List<String> preferredDurationsItemValueStrLst =
        preferredDurationsItemValue.split(regExp);
    List<String> parsedTimeStrLst = preferredDurationsItemValueStrLst
        .map((e) => formatStringDuration(
              durationStr: e,
              removeMinusSign: false,
            ))
        .toList();

    return parsedTimeStrLst;
  }

  /// Obtained from Circadian project Utility class.
  /// 
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

  /// Obtained from Circadian project Utility class.
  static String extractHHmmAtPosition({
    required String dataStr,
    required int pos,
  }) {
    if (pos > dataStr.length) {
      return '';
    }

    int newLineCharIdx = dataStr.lastIndexOf('\n');
    int leftIdx;

    if (pos > newLineCharIdx) {
      // the case if clicking on second line
      leftIdx = dataStr.substring(newLineCharIdx + 1, pos).lastIndexOf(' ') +
          newLineCharIdx;
    } else {
      leftIdx = dataStr.substring(0, pos).lastIndexOf(' ');
    }

    String extractedHHmmStr;

    if (leftIdx == -1) {
      // the case if selStartPosition is before the first space position
      leftIdx = 0;
    }

    int rightIdx = dataStr.indexOf(',', pos);

    if (rightIdx == -1) {
      // the case if the position is on the last HH:mm value
      rightIdx = dataStr.lastIndexOf(RegExp(r'-|\d')) + 1;
    }

    extractedHHmmStr = dataStr.substring(leftIdx, rightIdx);

    if (extractedHHmmStr.contains(RegExp(r'\D'))) {
      RegExpMatch? match = RegExp(r'(-|\d)+:\d+').firstMatch(extractedHHmmStr);

      if (match != null) {
        extractedHHmmStr = match.group(0) ?? '';
      }
    }

    return extractedHHmmStr;
  }

  /// Parses the passed hourMinuteStr formatted as hh:mm or h:mm or -hh:mm or
  /// -h:mm and returns the hh:mm, h:mm, -hh:mm or -h:mm parsed String or null
  /// if the passed hourMinuteStr does not respect the hh:mm or h:mm or -hh:mm
  /// or -h:mm format, like 03:2 or 3:2 or 03-02 or 03:a2 or -03:2 or -3:2 or
  /// -03-02 or -03:a2 for example.
  static String? parseDDHHMMTimeStr(String dayHhourMinuteStr) {
    final RegExpMatch? match = regExpDDHHMMTime.firstMatch(dayHhourMinuteStr);
    final String? parsedDayHourMinuteStr = match?.group(1);

    return parsedDayHourMinuteStr;
  }

  /// Parses the passed hourAnyMinuteStr formatted as hh:anymm or h:anymm or
  /// -hh:anymm or -h:anymm and returns the hh:anymm, h:anymm, -hh:anymm or
  /// -h:anymm parsed String or null if the passed hourAnyMinuteStr does not
  /// respect the hh:anymm or h:anymm or -hh:anymm or -h:anymm format, like
  /// 03-02 or 03:a2 or -03-02 or -03:a2 for example.
  static String? parseDDHHAnyMMTimeStr(String dayHhourAnyMinuteStr) {
    final RegExpMatch? match =
        regExpDDHHAnyMMTime.firstMatch(dayHhourAnyMinuteStr);
    final String? parsedDayHourMinuteStr = match?.group(1);

    return parsedDayHourMinuteStr;
  }

  /// Parses the passed HH:mm (12:35) hourMinuteStr and returns a Duration
  /// instanciated with the parsed hour and minute values.
  static Duration? parseHHMMDuration(String hourMinuteStr) {
    final String? parsedHourMinuteStr =
        DateTimeParser.parseHHMMTimeStr(hourMinuteStr);

    if (parsedHourMinuteStr != null) {
      List<String> hourMinuteStrLst = parsedHourMinuteStr.split(':');
      List<int> hourMinuteIntLst = hourMinuteStrLst
          .map((element) => int.parse(element))
          .toList(growable: false);

      final int hourInt = hourMinuteIntLst[0].abs();
      int minuteInt = hourMinuteIntLst[1].abs();

      Duration duration = Duration(hours: hourInt, minutes: minuteInt);

      if (hourMinuteStrLst[0].startsWith('-')) {
        return Duration.zero - duration;
      } else {
        return duration;
      }
    }

    return null;
  }

  /// Parses the passed dayHourMinuteStr and returns a Duration
  /// instanciated with the parsed day, hour and minute values.
  static Duration? parseDDHHMMDuration(String dayHourMinuteStr) {
    final String? parsedDayHourMinuteStr =
        DateTimeParser.parseDDHHMMTimeStr(dayHourMinuteStr);

    if (parsedDayHourMinuteStr != null) {
      List<String> dayHourMinuteStrLst = parsedDayHourMinuteStr.split(':');
      List<int> hourMinuteIntLst = dayHourMinuteStrLst
          .map((element) => int.parse(element))
          .toList(growable: false);

      int setNegative = 1;

      final int dayInt = hourMinuteIntLst[0];
      final int hourInt = hourMinuteIntLst[1];
      final int minuteInt = hourMinuteIntLst[2];

      Duration duration =
          Duration(days: dayInt, hours: hourInt, minutes: minuteInt);

      if (dayHourMinuteStr.startsWith('-00')) {
        return Duration.zero - duration;
      } else {
        return duration;
      }
    }

    return null;
  }

  /// Parses the passed dayHourMinuteStr or hourMinuteStr and
  /// returns a Duration instanciated with the parsed hour and
  /// minute values.
  static Duration? parseDDHHMMorHHMMDuration(String dayHourMinuteStr) {
    final String? parsedDayHourMinuteStr =
        DateTimeParser.parseDDHHMMTimeStr(dayHourMinuteStr);

    if (parsedDayHourMinuteStr != null) {
      return createDayHourMinuteDuration(parsedDayHourMinuteStr);
    } else {
      final String? parsedHourMinuteStr =
          DateTimeParser.parseHHMMTimeStr(dayHourMinuteStr);
      if (parsedHourMinuteStr != null) {
        return createHourMinuteDuration(parsedHourMinuteStr);
      }
    }

    return null;
  }

  static Duration createHourMinuteDuration(String parsedHourMinuteStr) {
    List<String> dayHourMinuteStrLst = parsedHourMinuteStr.split(':');
    List<int> hourMinuteIntLst = dayHourMinuteStrLst
        .map((element) => int.parse(element))
        .toList(growable: false);

    final int hourInt = hourMinuteIntLst[0].abs();
    final int minuteInt = hourMinuteIntLst[1].abs();

    Duration duration = Duration(hours: hourInt, minutes: minuteInt);

    if (parsedHourMinuteStr.startsWith('-')) {
      return Duration.zero - duration;
    } else {
      return duration;
    }
  }

  static Duration createDayHourMinuteDuration(String parsedDayHourMinuteStr) {
    List<String> dayHourMinuteStrLst = parsedDayHourMinuteStr.split(':');
    List<int> dayHourMinuteIntLst = dayHourMinuteStrLst
        .map((element) => int.parse(element))
        .toList(growable: false);

    final int dayInt = dayHourMinuteIntLst[0].abs();
    final int hourInt = dayHourMinuteIntLst[1].abs();
    final int minuteInt = dayHourMinuteIntLst[2].abs();

    Duration duration =
        Duration(days: dayInt, hours: hourInt, minutes: minuteInt);

    if (parsedDayHourMinuteStr.startsWith('-')) {
      return Duration.zero - duration;
    } else {
      return duration;
    }
  }

  /// Parses the passed dayHourAnyMinuteStr or hourAnyMinuteStr and
  /// returns a Duration instanciated with the parsed hour and
  /// minute values.
  ///
  /// Example dayHourAnyMinuteStr: 00:00:9125 or 00:9125
  static Duration? parseDDHHAnyMMorHHAnyMMDuration(String dayHourAnyMinuteStr) {
    final String? parsedDayHourAnyMinuteStr =
        DateTimeParser.parseDDHHAnyMMTimeStr(dayHourAnyMinuteStr);

    if (parsedDayHourAnyMinuteStr != null) {
      return createDayHourMinuteDuration(parsedDayHourAnyMinuteStr);
    } else {
      final String? parsedHourAnyMinuteStr =
          DateTimeParser.parseHHAnyMMTimeStr(dayHourAnyMinuteStr);
      if (parsedHourAnyMinuteStr != null) {
        return createHourMinuteDuration(parsedHourAnyMinuteStr);
      }
    }

    return null;
  }

  /// Returns the english formatted passed french formatted date
  /// time string. In case the passed date time string format
  /// is invalid, null is returned.
  static String? convertFrenchFormatToEnglishFormatDateTimeStr(
      {required String frenchFormatDateTimeStr}) {
    DateTime? endDateTime;
    String? englishFormatDateTimeStr;

    try {
      endDateTime =
          frenchDateTimeFormat.parse(frenchFormatDateTimeStr);
    } on FormatException {}

    if (endDateTime != null) {
      englishFormatDateTimeStr =
          englishDateTimeFormat.format(endDateTime);
    }

    return englishFormatDateTimeStr;
  }

  /// Returns the french formatted passed english formatted date
  /// time string. In case the passed date time string format
  /// is invalid, null is returned.
  static String? convertEnglishFormatToFrenchFormatDateTimeStr(
      {required String englishFormatDateTimeStr}) {
    DateTime? endDateTime;
    String? frenchFormatDateTimeStr;

    try {
      endDateTime =
          englishDateTimeFormat.parse(englishFormatDateTimeStr);
    } on FormatException {}

    if (endDateTime != null) {
      frenchFormatDateTimeStr =
          frenchDateTimeFormat.format(endDateTime);
    }

    return frenchFormatDateTimeStr;
  }

  /// Examples: 2021-01-01T10:35 --> 2021-01-01T11:00
  ///           2021-01-01T10:25 --> 2021-01-01T10:00
  static DateTime roundDateTimeToHour(DateTime dateTime) {
    if (dateTime.minute >= 30) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour + 1, 0, 0, 0, 0);
    } else {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour, 0, 0, 0, 0);
    }
  }
}
