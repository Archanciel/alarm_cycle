import 'package:flutter/foundation.dart';

import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../util/date_time_parser.dart';

class AlarmVM extends ChangeNotifier {
  final AlarmService _alarmService;
  int _lastAlarmId = 1;

  AlarmVM(this._alarmService);

  Future<void> schedulePeriodicAlarm({
    required String alarmHHmmPeriodicity,
    required String startAlarmHHmm,
  }) async {
    Alarm alarm = Alarm(
      alarmId: _lastAlarmId++,
      alarmHHmmPeriodicity: alarmHHmmPeriodicity,
      startAlarmDateTime:
          DateTimeParser.englishDateTimeFormat.parse(startAlarmHHmm),
    );

    print(
        "********** SET startAlarmHHmm: ${DateTimeParser.englishDateTimeFormat.format(alarm.startAlarmDateTime)}\n********** alarmHHmmPeriodicity: ${alarm.alarmHHmmPeriodicity}");

    await _alarmService.schedulePeriodicAlarm(
      alarm: alarm,
    );
  }

  Future<void> deletePeriodicAlarm({
    required int alarmId,
  }) async {
    print(
        "********** DELETE alarmId: $alarmId");

    await _alarmService.cancelPeriodicAlarm(
      alarmId: alarmId,
    );
  }
}
