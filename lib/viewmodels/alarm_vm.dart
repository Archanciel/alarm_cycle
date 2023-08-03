import 'package:flutter/foundation.dart';

import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../util/date_time_parser.dart';

class AlarmVM extends ChangeNotifier {
  final AlarmService _alarmService;
  int _lastAlarmId = 1;
  List<Alarm> _alarmLst = [];
  List<Alarm> get alarmLst => _alarmLst;
  int _selectedAlarmId = 0;
  set selectedAlarmId(int alarmId) {
    _selectedAlarmId = alarmId;

    notifyListeners();
  }

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

    _alarmLst.add(alarm);

    print(
        "********** SET startAlarmHHmm: ${DateTimeParser.englishDateTimeFormat.format(alarm.startAlarmDateTime)}\n********** alarmHHmmPeriodicity: ${alarm.alarmHHmmPeriodicity}");

    await _alarmService.schedulePeriodicAlarm(
      alarm: alarm,
    );
  }

  Future<void> deletePeriodicAlarm({
    required int alarmId,
  }) async {
    print("********** DELETE alarmId: $alarmId");

    await _alarmService.cancelPeriodicAlarm(
      alarmId: alarmId,
    );

    _alarmLst.removeWhere((alarm) => alarm.alarmId == alarmId);

    notifyListeners();
  }

  void editAlarm({
    required int alarmId,
    required String title,
    required String description,
  }) {
    Alarm alarm = _alarmLst.firstWhere((alarm) => alarm.alarmId == alarmId);
  }

  Future<void> addAlarm({
    required String title,
    required String description,
    required String alarmHHmmPeriodicity,
    required String startAlarmHHmm,
  }) async {
    DateTime startAlarmDateTime;

    try {
      startAlarmDateTime =
          DateTimeParser.englishDateTimeFormat.parse(startAlarmHHmm);
    } catch (e) {
      startAlarmDateTime = DateTime.now();
    }

    Alarm alarm = Alarm(
      alarmId: _lastAlarmId++,
      alarmHHmmPeriodicity: alarmHHmmPeriodicity,
      startAlarmDateTime: startAlarmDateTime,
      title: title,
      description: description,
    );

    _alarmLst.add(alarm);

    print(
        "********** SET startAlarmHHmm: ${DateTimeParser.englishDateTimeFormat.format(alarm.startAlarmDateTime)}\n********** alarmHHmmPeriodicity: ${alarm.alarmHHmmPeriodicity}");

    await _alarmService.schedulePeriodicAlarm(
      alarm: alarm,
    );

    notifyListeners();
  }

  Alarm selectedAlarm() {
    return _alarmLst.firstWhere((alarm) => alarm.alarmId == _selectedAlarmId,
        // returning null is not allowed. Instead, an Alarm with alarmId = 0
        // is returned.
        orElse: () => Alarm(
              alarmId: 0,
              alarmHHmmPeriodicity: "",
              startAlarmDateTime: DateTime.now(),
            ));
  }
}
