import 'package:flutter/foundation.dart';

import '../services/alarm_service.dart';

class AlarmViewModel extends ChangeNotifier {
  final AlarmService _alarmService;

  AlarmViewModel(this._alarmService);

  Future<void> schedulePeriodicAlarm({
    required String alarmHHmmPeriodicity,
    required String startAlarmHHmm,
  }) async {
    print(
        "********** SET startAlarmHHmm: $startAlarmHHmm\n********** alarmHHmmPeriodicity: $alarmHHmmPeriodicity");

    await _alarmService.schedulePeriodicAlarm(
      alarmHHmmPeriodicity: alarmHHmmPeriodicity,
      startAlarmHHmm: startAlarmHHmm,
    );
  }

  Future<void> deletePeriodicAlarm({
    required String alarmHHmmPeriodicity,
    required String startAlarmHHmm,
  }) async {
    print(
        "********** DELETE startAlarmHHmm: $startAlarmHHmm\n********** alarmHHmmPeriodicity: $alarmHHmmPeriodicity");

    await _alarmService.cancelPeriodicAlarm(
      alarmHHmmPeriodicity: alarmHHmmPeriodicity,
      startAlarmHHmm: startAlarmHHmm,
    );
  }
}
