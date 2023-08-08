import 'package:alarm_cycle/util/date_time_parser.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';

const String appName = "Alarm Manager Example";

class SoundService {
  final String soundPath;
  late final AudioPlayer _audioPlayer;

  SoundService(this.soundPath) {
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  void _initializePlayer() async {
    await _audioPlayer.setSourceAsset(soundPath);
  }

  Future<void> playAlarmSound() async {
    await _audioPlayer.play(AssetSource(soundPath));
  }
}

class AlarmService {
  static final SoundService soundServiceSirdalud =
      SoundService('audio/Sirdalud.mp3');
  static final SoundService soundServiceLioresal =
      SoundService('audio/Lioresal.mp3');
  static final Map<int, SoundService> soundServices = {
    1: soundServiceSirdalud,
    2: soundServiceLioresal,
  };

  static void periodicTaskCallbackFunctionSirdalud() {
    print("*** Periodic Task Running for alarm ID 1. Time is ${DateTime.now()}");
    soundServices[1]!.playAlarmSound();
  }

  static void periodicTaskCallbackFunctionLioresal() {
    print("*** Periodic Task Running for alarm ID 2. Time is ${DateTime.now()}");
    soundServices[2]!.playAlarmSound();
  }

  static final Map<int, Function> periodicTaskCallbackFunctions = {
    1: periodicTaskCallbackFunctionSirdalud,
    2: periodicTaskCallbackFunctionLioresal,
  };

  Future<void> schedulePeriodicAlarm({
    required Duration duration,
    required int id,
  }) async {
    print(
        "********** SET alarmId: $id\n********** startAlarmHHmm: ${DateTimeParser.englishDateTimeFormat.format(DateTime.now())}\n********** alarmHHmmPeriodicity: ${duration.HHmm()}\n********** soundPath: ${soundServices[id]!.soundPath}");
    await AndroidAlarmManager.periodic(
      duration,
      id,
      periodicTaskCallbackFunctions[id]!,
      exact: true,
      wakeup: true,
    );
  }

  Future<void> cancelPeriodicAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
    soundServices.remove(id);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: AlarmScreen(),
    );
  }
}

class AlarmScreen extends StatelessWidget {
  final AlarmService _alarmService = AlarmService();

  AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await _alarmService.schedulePeriodicAlarm(
                duration: const Duration(minutes: 3),
                id: 1,
              );
            },
            child: const Text('Set Alarm 1 (3 minutes, sound 1)'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _alarmService.schedulePeriodicAlarm(
                duration: const Duration(minutes: 5),
                id: 2,
              );
            },
            child: const Text('Set Alarm 2 (5 minutes, sound 2)'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _alarmService.cancelPeriodicAlarm(1);
            },
            child: const Text('Cancel Alarm 1'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _alarmService.cancelPeriodicAlarm(2);
            },
            child: const Text('Cancel Alarm 2'),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}
