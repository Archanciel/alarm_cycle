// https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md

import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

const String appName = "Alarm Manager Example";

class AlarmSettings {
  final Duration periodicity;
  final String soundAssetPath;

  AlarmSettings(
    this.periodicity,
    this.soundAssetPath,
  );
}

class SoundService {
  late AudioPlayer _audioPlayer;

  SoundService() {
    _audioPlayer = AudioPlayer();
  }

  /// Asset definition in pubspec.yaml
  ///
  ///   assets:
  ///     - assets/audio/
  ///
  /// {soundAssetPath} example: 'audio/mixkit-facility-alarm-sound-999.mp3'
  Future<void> playAlarmSound({
    required String soundAssetPath,
  }) async {
    await _audioPlayer.play(AssetSource(soundAssetPath));
  }
}

class AlarmService {
  final Map<int, AlarmSettings> alarms = {};
  final SoundService soundService;

  AlarmService(this.soundService);

  Future<void> schedulePeriodicAlarm({
    required alarmId,
    required settings,
  }) async {
    alarms[alarmId] = settings;

    await AndroidAlarmManager.periodic(
      settings.periodicity,
      alarmId,
      () => periodicTaskCallbackFunction(alarmId),
    );
  }

  void periodicTaskCallbackFunction(int alarmId) {
    print("Periodic Task Running for Alarm ID: $alarmId");
    AlarmSettings? settings = alarms[alarmId];
    if (settings != null) {
      soundService.playAlarmSound(
        soundAssetPath: settings.soundAssetPath,
      );
    }
  }

  Future<void> cancelPeriodicAlarm({
    required int alarmId,
  }) async {
    await AndroidAlarmManager.cancel(alarmId);
  }
}

class AlarmViewModel extends ChangeNotifier {
  static const List<String> availableSoundAssetPaths = [
    "audio/mixkit-facility-alarm-sound-999.mp3",
    "audio/mixkit-city-alert-siren-loop-1008.mp3",
    "audio/mixkit-interface-hint-notification-911.mp3",
    "audio/mixkit-scanning-sci-fi-alarm-905.mp3",
  ];

  int lastAlarmId = 1;
  final AlarmService _alarmService;

  AlarmViewModel(this._alarmService);

  Future<void> schedulePeriodicAlarm({
    required String minuteNumber,
    required String startAlarmHHmm,
  }) async {
    AlarmSettings settings = AlarmSettings(
      Duration(minutes: int.parse(minuteNumber)),
      availableSoundAssetPaths[lastAlarmId % availableSoundAssetPaths.length],
    );

    print(
        "********** SET alarm id: $lastAlarmId \n********** startAlarmHHmm: $startAlarmHHmm\n********** alarmHHmmPeriodicity: $minuteNumber\n********** sound: ${settings.soundAssetPath}}");

    await _alarmService.schedulePeriodicAlarm(
      alarmId: lastAlarmId++,
      settings: settings,
    );
  }

  Future<void> deletePeriodicAlarm({
    required String alarmHHmmPeriodicity,
    required String startAlarmHHmm,
  }) async {
    print(
        "********** DELETE startAlarmHHmm: $startAlarmHHmm\n********** alarmHHmmPeriodicity: $alarmHHmmPeriodicity");

    await _alarmService.cancelPeriodicAlarm(
      alarmId: lastAlarmId--,
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final String minutesLabel = "Minutes";
  final String hoursLabel = "Hours";
  final String periodicAlarmLabel = "Periodic";
  final String deleteAlarmLabel = "Delete";

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        String minuteNumber = await _chooseDuration(context);
                        await Provider.of<AlarmViewModel>(context,
                                listen: false)
                            .schedulePeriodicAlarm(
                          minuteNumber: minuteNumber,
                          startAlarmHHmm: DateTime.now().toString(),
                        );
                      },
                      icon: const Icon(Icons.watch_later_outlined),
                      label: Text(periodicAlarmLabel)),
                ),
                const SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        Provider.of<AlarmViewModel>(context, listen: false)
                            .deletePeriodicAlarm(
                          alarmHHmmPeriodicity: '',
                          startAlarmHHmm: DateTime.now().toString(),
                        );
                      },
                      icon: const Icon(Icons.watch_later_outlined),
                      label: Text(deleteAlarmLabel)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<String> _chooseDuration(BuildContext context) async {
    String alarmPeriodicityMinuteStr = '';

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter a minute number for the duration"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (String text) {
                              alarmPeriodicityMinuteStr = text;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(alarmPeriodicityMinuteStr);
                },
                child: const Text("Ok"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              )
            ],
          );
        });

    return alarmPeriodicityMinuteStr;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: appName),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AlarmViewModel(
        AlarmService(
          SoundService(),
        ),
      ),
      child: const MyApp(),
    ),
  );
}
