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
  int get selectedAlarmId => _selectedAlarmId;
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
      soundAssetPath: "audio/mixkit-facility-alarm-sound-999.mp3",
      title: title,
      description: description,
    );

    _alarmsMap[alarmId] = alarm;

    print(
        "********** SET alarmId: $alarmId\n********** startAlarmHHmm: ${DateTimeParser.englishDateTimeFormat.format(alarm.startAlarmDateTime)}\n********** alarmHHmmPeriodicity: ${alarm.alarmHHmmPeriodicity}");

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

    notifyListeners();
  }

  Alarm getSelectedAlarm() {
    return _alarmsMap[_selectedAlarmId]!;
  }

  void selectAlarm({
    required alarmId,
  }) {
    if (_selectedAlarmId == alarmId) {
      // Deselect alarm if tapping on already selected alarm
      _selectedAlarmId = 0;
    } else {
      _selectedAlarmId = alarmId;
    }

    notifyListeners();
  }
}
