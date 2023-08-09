import 'package:alarm_cycle/services/sound_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../models/alarm.dart';
import '../util/date_time_parser.dart';

class AlarmService {
  static const List<String> availableSoundAssetPaths = [
    "audio/Lioresal.mp3",
    "audio/Sirdalud.mp3",
  ];

  static const int soundsNumber = 2;

  // The AndroidAlarmManager.periodic method requires a callback
  // function that has no parameters. This is due to the way Dart's
  // Isolate communicates with the main application. When the callback
  // function is executed, it does not have access to the state of the
  // app when the function was scheduled. Therefore, the function and
  // its parameters should not depend on the instance state of your
  // application, which is why static functions are usually used.
  static final SoundService staticSoundServiceOne = SoundService();
  static final SoundService staticSoundServiceTwo = SoundService();
  static final SoundService staticSoundServiceThree = SoundService();

  static final List<SoundService> staticSoundServiceList = [
    staticSoundServiceOne,
    staticSoundServiceTwo,
    staticSoundServiceThree,
  ];

  static void periodicTaskCallbackFunctionOne() {
    print("*** Periodic task running at ${DateTime.now()}\n*** Sound: ${availableSoundAssetPaths[0]}");
    staticSoundServiceOne.playAlarmSound(
      soundAssetPath: availableSoundAssetPaths[0],
    );
  }

  static void periodicTaskCallbackFunctionTwo() {
    print("*** Periodic task running at ${DateTime.now()}\n*** Sound: ${availableSoundAssetPaths[1]}");
    staticSoundServiceTwo.playAlarmSound(
      soundAssetPath: availableSoundAssetPaths[1],
    );
  }

  static final List<Function> periodicTaskCallbackFunctionList = [
    periodicTaskCallbackFunctionOne,
    periodicTaskCallbackFunctionTwo,
  ];

  Future<void> schedulePeriodicAlarm({
    required Alarm alarm,
  }) async {
    Duration? parseHHMMDuration =
        DateTimeParser.parseHHMMDuration(alarm.alarmHHmmPeriodicity);

    if (parseHHMMDuration != null) {
      // Here's what each of these named parameters signifies in the
      // `AndroidAlarmManager.periodic()` function:
      //
      // 1. `exact`: A boolean parameter. When set to true, the alarm will
      // go off at the exact time of the alarm. When set to false (default),
      // the alarm may go off a little before its set time. This is because
      // Android can shift alarms in batches to conserve power.
      //
      // 2. `wakeup`: A boolean parameter. If this is set to true, the alarm
      // will wake up the device when it goes off. If false, the alarm will
      // not wake up the device, meaning if the device is in sleep mode when
      // the alarm goes off, it won't be woken up and the alarm might not go
      // off until the device is next awakened.
      //
      // 3. `startAt`: A `DateTime` parameter. It defines when the first
      // alarm should go off. For example, if you want the first alarm to
      // go off 5 seconds from now, you can set it as
      // `startAt: DateTime.now().add(Duration(seconds: 5))`.
      //
      // 4. `alarmClock`: A boolean parameter. When this is set to true,
      // the alarm will be set as an alarm clock, meaning it will be shown
      // to the user in the status bar and the alarm clock UI.
      //
      // 5. `allowWhileIdle`: A boolean parameter. When set to true, the
      // alarm can also go off while the device is in idle mode. This is
      // useful for critical alarms that need to go off even if the device
      // is in battery-saving modes.
      //
      // 6. `rescheduleOnReboot`: A boolean parameter. When set to true,
      // the alarm will be rescheduled after the device reboots. Note that
      // you'll need to declare the
      // `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>`
      // permission in your manifest file to use this.
      await AndroidAlarmManager.periodic(
        parseHHMMDuration,
        alarm.alarmId,
        periodicTaskCallbackFunctionList[alarm.alarmId % soundsNumber],
        exact: true,
        startAt: alarm.startAlarmDateTime.add(parseHHMMDuration),
      );
    }
  }

  Future<void> cancelPeriodicAlarm({
    required int alarmId,
  }) async {
    await AndroidAlarmManager.cancel(alarmId);
  }
}
