import 'package:alarm_cycle/services/sound_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../models/alarm.dart';
import '../util/date_time_parser.dart';

class AlarmService {
  static final List<String> availableSoundAssetPaths = [
    "audio/mixkit-city-alert-siren-loop-1008.mp3",
    "audio/mixkit-facility-alarm-sound-999.mp3",
    "audio/mixkit-scanning-sci-fi-alarm-905.mp3",
  ];

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
    print("*********** Periodic Task Running. Time is ${DateTime.now()}\n*********** sound: ${availableSoundAssetPaths[0]}");
    staticSoundServiceOne.playAlarmSound(
      soundAssetPath: availableSoundAssetPaths[0],
    );
  }

  static void periodicTaskCallbackFunctionTwo() {
    print("*********** Periodic Task Running. Time is ${DateTime.now()}\n*********** sound: ${availableSoundAssetPaths[1]}");
    staticSoundServiceTwo.playAlarmSound(
      soundAssetPath: availableSoundAssetPaths[1],
    );
  }

  static void periodicTaskCallbackFunctionThree() {
    print("*********** Periodic Task Running. Time is ${DateTime.now()}\n*********** sound: ${availableSoundAssetPaths[2]}");
    staticSoundServiceThree.playAlarmSound(
      soundAssetPath: availableSoundAssetPaths[2],
    );
  }

  static final List<Function> periodicTaskCallbackFunctionList = [
    periodicTaskCallbackFunctionOne,
    periodicTaskCallbackFunctionTwo,
    periodicTaskCallbackFunctionThree,
  ];

  Future<void> schedulePeriodicAlarm({
    required Alarm alarm,
  }) async {
    staticSoundServiceList[alarm.alarmId % 4].setSoundAssetPath(
      soundAssetPath: alarm.soundAssetPath,
    );

    Duration? parseHHMMDuration =
        DateTimeParser.parseHHMMDuration(alarm.alarmHHmmPeriodicity);

    if (parseHHMMDuration != null) {
      await AndroidAlarmManager.periodic(
        parseHHMMDuration,
        alarm.alarmId,
        periodicTaskCallbackFunctionList[alarm.alarmId % 4],
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
