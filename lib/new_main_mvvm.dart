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
  static final Map<int, SoundService> _soundServices = {};

  static void registerSoundService(int id, SoundService soundService) {
    _soundServices[id] = soundService;
  }

  static void periodicTaskCallbackFunction(int id) {
    print("Periodic Task Running for alarm ID $id. Time is ${DateTime.now()}");
    _soundServices[id]?.playAlarmSound();
  }

  Future<void> schedulePeriodicAlarm({
    required Duration duration,
    required int id,
    required String soundPath,
  }) async {
    registerSoundService(id, SoundService(soundPath));
    await AndroidAlarmManager.periodic(
      duration,
      id,
      (id) => periodicTaskCallbackFunction(id),
      exact: true,
      wakeup: true,
    );
  }

  Future<void> cancelPeriodicAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
    _soundServices.remove(id);
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
                duration: const Duration(minutes: 2),
                id: 1,
                soundPath: 'audio/Lioresal.mp3',
              );
            },
            child: const Text('Set Alarm 1 (3 minutes, sound 1)'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _alarmService.schedulePeriodicAlarm(
                duration: const Duration(minutes: 3),
                id: 2,
                soundPath: 'audio/Sirdalud.mp3',
              );
            },
            child: const Text('Set Alarm 2 (2 minutes, sound 2)'),
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
