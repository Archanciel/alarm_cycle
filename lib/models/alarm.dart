import 'package:alarm_cycle/util/date_time_parser.dart';

class Alarm {
  final int alarmId;
  final String alarmHHmmPeriodicity;
  final DateTime startAlarmDateTime;

  String title;
  String description;

  Alarm({
    required this.alarmId,
    required this.alarmHHmmPeriodicity,
    required this.startAlarmDateTime,
    this.title = "",
    this.description = "",
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      alarmId: json['alarmId'],
      alarmHHmmPeriodicity: json['alarmHHmmPeriodicity'],
      startAlarmDateTime: DateTimeParser.englishDateTimeFormat
          .parse(json['startAlarmDateTimeStr']),
    );
  }

  Map<String, dynamic> toJson() => {
        'alarmId': alarmId,
        'alarmHHmmPeriodicity': alarmHHmmPeriodicity,
        'startAlarmDateTimeStr':
            DateTimeParser.englishDateTimeFormat.format(startAlarmDateTime),
      };
}
