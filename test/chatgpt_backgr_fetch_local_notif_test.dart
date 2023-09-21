// test/chatgpt_backgr_fetch_local_notif_test.dart

import 'package:alarm_cycle/models/alarm.dart';
import 'package:alarm_cycle/util/date_time_parser.dart';
import 'package:alarm_cycle/viewmodels/alarm_vm.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('checkAlarmsPeriodically', () {
    test(
        'updates an alarm with next alarm time before now but after now minus periodicDuration or after lastAlarmTimePurpose',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const Duration periodicDuration = Duration(hours: 5);

      DateTime now = DateTime.now();
      DateTime lastAlarmTimePurpose = DateTimeParser.truncateDateTimeToMinute(
          now.subtract(periodicDuration));

      // subtracting one hours to test the case when the alarm is checked
      // one hour after its nextAlarmTime
      lastAlarmTimePurpose =
          lastAlarmTimePurpose.subtract(const Duration(hours: 1));

      Alarm alarm = Alarm(
        name: 'test',
        lastAlarmTimePurpose: lastAlarmTimePurpose,
        lastAlarmTimeReal: lastAlarmTimePurpose.add(const Duration(minutes: 7)),
        nextAlarmTime: lastAlarmTimePurpose.add(periodicDuration),
        periodicDuration: periodicDuration,
        audioFilePathName: '',
      );

      Alarm initialAlarm = Alarm.copy(originalAlarm: alarm);

      AlarmVM().updateAlarmDateTimes(alarm: alarm);

      // Assert
      expect(alarm.lastAlarmTimePurpose, initialAlarm.nextAlarmTime);
      final Duration difference =
          alarm.lastAlarmTimeReal!.difference(now).abs();
      expect(difference.inSeconds <= 1, true);
      expect(alarm.nextAlarmTime,
          initialAlarm.nextAlarmTime.add(periodicDuration));
    });

    test(
        'updates an alarm with next alarm time before now minus 2 periodicDuration',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const Duration periodicDuration = Duration(hours: 5);

      DateTime now = DateTime.now();
      DateTime lastAlarmTimePurpose = DateTimeParser.truncateDateTimeToMinute(
          now.subtract(periodicDuration * 2));

      Alarm alarm = Alarm(
        name: 'test',
        lastAlarmTimePurpose: lastAlarmTimePurpose,
        lastAlarmTimeReal: lastAlarmTimePurpose.add(const Duration(minutes: 7)),
        nextAlarmTime: lastAlarmTimePurpose.add(periodicDuration),
        periodicDuration: periodicDuration,
        audioFilePathName: '',
      );

      Alarm initialAlarm = Alarm.copy(originalAlarm: alarm);

      AlarmVM().updateAlarmDateTimes(alarm: alarm);

      // Assert
      expect(alarm.lastAlarmTimePurpose, initialAlarm.nextAlarmTime);
      final Duration difference =
          alarm.lastAlarmTimeReal!.difference(now).abs();
      expect(difference.inSeconds <= 1, true);
      expect(alarm.nextAlarmTime,
          DateTimeParser.truncateDateTimeToMinute(now).add(periodicDuration));
    });
    test(
        'updates an alarm with next alarm time before now minus 3 periodicDuration',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const Duration periodicDuration = Duration(hours: 5);

      DateTime now = DateTime.now();
      DateTime lastAlarmTimePurpose = DateTimeParser.truncateDateTimeToMinute(
          now.subtract(periodicDuration * 3));

      Alarm alarm = Alarm(
        name: 'test',
        lastAlarmTimePurpose: lastAlarmTimePurpose,
        lastAlarmTimeReal: lastAlarmTimePurpose.add(const Duration(minutes: 7)),
        nextAlarmTime: lastAlarmTimePurpose.add(periodicDuration),
        periodicDuration: periodicDuration,
        audioFilePathName: '',
      );

      Alarm initialAlarm = Alarm.copy(originalAlarm: alarm);

      AlarmVM().updateAlarmDateTimes(alarm: alarm);

      // Assert
      expect(alarm.lastAlarmTimePurpose, initialAlarm.nextAlarmTime);
      final Duration difference =
          alarm.lastAlarmTimeReal!.difference(now).abs();
      expect(difference.inSeconds <= 1, true);
      expect(alarm.nextAlarmTime,
          DateTimeParser.truncateDateTimeToMinute(now).add(periodicDuration));
    });
    test(
        'updates an alarm with next alarm time before now minus 1.5 periodicDuration',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const Duration periodicDuration = Duration(hours: 5);

      DateTime now = DateTime.now();
      DateTime lastAlarmTimePurpose = DateTimeParser.truncateDateTimeToMinute(
          now.subtract(periodicDuration * 1.5));

      Alarm alarm = Alarm(
        name: 'test',
        lastAlarmTimePurpose: lastAlarmTimePurpose,
        lastAlarmTimeReal: lastAlarmTimePurpose.add(const Duration(minutes: 7)),
        nextAlarmTime: lastAlarmTimePurpose.add(periodicDuration),
        periodicDuration: periodicDuration,
        audioFilePathName: '',
      );

      Alarm initialAlarm = Alarm.copy(originalAlarm: alarm);

      AlarmVM().updateAlarmDateTimes(alarm: alarm);

      // Assert
      expect(alarm.lastAlarmTimePurpose, initialAlarm.nextAlarmTime);
      final Duration difference =
          alarm.lastAlarmTimeReal!.difference(now).abs();
      expect(difference.inSeconds <= 1, true);
      expect(alarm.nextAlarmTime,
          initialAlarm.nextAlarmTime.add(periodicDuration));
    });
  });
}
