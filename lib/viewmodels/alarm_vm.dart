import 'package:flutter/foundation.dart';

import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../util/date_time_parser.dart';

class AlarmVM extends ChangeNotifier {
  final AlarmService _alarmService;
  int _lastAlarmId = 1;
  final Map<int, Alarm> _alarmsMap = {};
  Map<int, Alarm> get alarmsMap => _alarmsMap;
  int _selectedAlarmId = 0;
  set selectedAlarmId(int alarmId) {
    _selectedAlarmId = alarmId;

    notifyListeners();
  }

  AlarmVM(this._alarmService);

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

    int alarmId = _lastAlarmId++;

    Alarm alarm = Alarm(
      alarmId: alarmId,
      alarmHHmmPeriodicity: alarmHHmmPeriodicity,
      startAlarmDateTime: startAlarmDateTime,
      title: title,
      description: description,
    );

    _alarmsMap[alarmId] = alarm;

    print(
        "********** SET startAlarmHHmm: ${DateTimeParser.englishDateTimeFormat.format(alarm.startAlarmDateTime)}\n********** alarmHHmmPeriodicity: ${alarm.alarmHHmmPeriodicity}");

    await _alarmService.schedulePeriodicAlarm(
      alarm: alarm,
    );

    notifyListeners();
  }

  Future<void> deleteAlarm({
    required int alarmId,
  }) async {
    print("********** DELETE alarmId: $alarmId");

    await _alarmService.cancelPeriodicAlarm(
      alarmId: alarmId,
    );

    _alarmsMap.remove(alarmId);

    notifyListeners();
  }

  void editAlarm({
    required int alarmId,
    required String title,
    required String description,
  }) {
    Alarm alarm = _alarmsMap[alarmId]!;

    alarm.title = title;
    alarm.description = description;
  }

  Alarm selectedAlarm() {
    return _alarmsMap[_selectedAlarmId]!;
  }
}
