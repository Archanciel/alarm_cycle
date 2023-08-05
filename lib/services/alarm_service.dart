import 'package:alarm_cycle/services/sound_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../models/alarm.dart';
import '../util/date_time_parser.dart';

class AlarmService {
  // The AndroidAlarmManager.periodic method requires a callback
  // function that has no parameters. This is due to the way Dart's
  // Isolate communicates with the main application. When the callback
  // function is executed, it does not have access to the state of the
  // app when the function was scheduled. Therefore, the function and
  // its parameters should not depend on the instance state of your
  // application, which is why static functions are usually used.
  static final SoundService staticSoundService = SoundService(
    soundAssetPath: 'audio/mixkit-facility-alarm-sound-999.mp3',
  );

  static void periodicTaskCallbackFunction() {
    print("Periodic Task Running. Time is ${DateTime.now()}");
    staticSoundService.playAlarmSound();
  }

  Future<void> schedulePeriodicAlarm({
    required Alarm alarm,
  }) async {
    Duration? parseHHMMDuration =
        DateTimeParser.parseHHMMDuration(alarm.alarmHHmmPeriodicity);

    if (parseHHMMDuration != null) {
      await AndroidAlarmManager.periodic(
        parseHHMMDuration,
        alarm.alarmId,
        periodicTaskCallbackFunction,
        startAt: alarm.startAlarmDateTime,
      );
    }
  }

  Future<void> cancelPeriodicAlarm({
    required int alarmId,
  }) async {
    await AndroidAlarmManager.cancel(alarmId);
  }
}
