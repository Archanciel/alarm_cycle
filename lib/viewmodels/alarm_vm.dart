import 'dart:convert';
import 'dart:io';

import 'package:alarm_cycle/constant.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import '../models/alarm.dart';
import '../views/simple_edit_alarm_screen.dart';

class AudioPlayerVM extends ChangeNotifier {
  /// Play an audio file located in the assets folder.
  ///
  /// Example: audioFilePath = 'audio/Sirdalud.mp3' if
  /// the audio file is located in the assets/audio folder.
  Future<void> playFromAssets(Alarm alarm) async {
    AudioPlayer? audioPlayer = alarm.audioPlayer;

    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
      alarm.audioPlayer = audioPlayer;
    }

    await audioPlayer.play(AssetSource(alarm.audioFilePathName));
    alarm.isPlaying = true;

    notifyListeners();
  }

  Future<void> pause(Alarm alarm) async {
    // Stop the audio
    if (alarm.isPaused) {
      await alarm.audioPlayer!.resume();
    } else {
      await alarm.audioPlayer!.pause();
    }

    alarm.invertPaused();

    notifyListeners();
  }

  Future<void> stop(Alarm alarm) async {
    // Stop the audio
    await alarm.audioPlayer!.stop();
    alarm.isPlaying = false;
    notifyListeners();
  }
}

/// The ViewModel of the AlarmPage is a singleton. This is because
/// the checkAlarmsPeriodically() method is passed to BackgroundFetch
/// as a static callback method. So, the callback method must be a
/// member of a singleton in order to access to the alarms list of
/// the singleton.
///
/// When the `checkAlarmsPeriodically` function is moved to be a static
/// or top-level function, you'll lose access to the instance-specific
/// properties and methods of `AlarmVM`. You'll need a mechanism to get
/// the current instance of `AlarmVM` in the function. Here are some
/// strategies:
///
/// 1. **Global Variable**:
///    A simple but not always ideal method. If there's only ever one
///    instance of `AlarmVM`, you could have a global variable that
///    points to it.
///
/// 2. **Singleton**:
///    If the `AlarmVM` class should have only one instance, you can
///    implement it as a singleton.
class AlarmVM with ChangeNotifier {
  List<Alarm> alarms = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AudioPlayerVM audioPlayerVM = AudioPlayerVM();

  static const List<String> audioFileNames = [
    'Sirdalud.mp3',
    'Lioresal.mp3',
    'ArrosePlante.mp3',
    // ... other files
  ];

  String _selectedAudioFile = audioFileNames.first;
  String get selectedAudioFile => _selectedAudioFile;
  set selectedAudioFile(String newValue) {
    _selectedAudioFile = newValue;

    notifyListeners();
  }

  static final AlarmVM _singleton = AlarmVM._internal();

  factory AlarmVM() {
    return _singleton;
  }

  AlarmVM._internal() {
    _loadAlarms();
    _initializeNotifications();
  }

  Future<void> _loadAlarms() async {
    // Chargez les alarmes à partir du fichier JSON
    // Utilisez path_provider pour obtenir le chemin du fichier JSON

    final directory = await getApplicationDocumentsDirectory();
    final filePath = File('${directory.path}/alarms.json');

    // Vérifiez si le fichier existe
    if (await filePath.exists()) {
      // Lisez et décodez le fichier
      final jsonData = await filePath.readAsString();
      final List<dynamic> loadedAlarms = json.decode(jsonData);

      alarms = loadedAlarms.map((alarmMap) {
        return Alarm.fromJson(alarmMap);
      }).toList();

      notifyListeners(); // Avertir les écouteurs que les alarmes ont été mises à jour
    }
  }

  Future<void> _saveAlarms() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = File('${directory.path}/alarms.json');

    // Convert alarms to a list of maps
    final List<Map<String, dynamic>> jsonAlarms = alarms.map((alarm) {
      return alarm.toJson();
    }).toList();

    // Encode and write to the file
    await filePath.writeAsString(json.encode(jsonAlarms));
  }

  /// Method called by BackgroundFetch every 15 minutes to check if
  /// an alarm should be triggered. If an alarm is triggered, its
  /// nextAlarmTime is updated and the updated alarm is saved to the
  /// JSON file.
  Future<void> checkAlarmsPeriodically(String taskId) async {
    bool wasAlarnModified = false;

    DateTime now = DateTime.now();

    for (Alarm alarm in alarms) {
      if (alarm.nextAlarmTime.isBefore(now)) {
        _displayAndroidNotification(alarm);
        await audioPlayerVM.playFromAssets(alarm);

        // Update the nextAlarmTime
        // alarm.nextAlarmTime = DateTimeParser.truncateDateTimeToMinute(now)
        //     .add(alarm.periodicDuration);
        updateAlarmDateTimes(
          alarm: alarm,
        );
        wasAlarnModified = true;
      }
    }

    if (wasAlarnModified) {
      _saveAlarms();

      notifyListeners();
    }

    // Important: end the task here, or the OS could be kill the app
    BackgroundFetch.finish(taskId);
  }

  /// This method is unit tested and so can't be private.
  void updateAlarmDateTimes({
    required Alarm alarm,
  }) {
    DateTime nextAlarmDateTime = alarm.nextAlarmTime;
    Duration periodicDuration = alarm.periodicDuration;

    // it can happen that a previous alarm was not triggered. In this
    // case, the nextAlarmDateTime + the periodicDuration would be in
    // the past. So, we need to add the periodicDuration to the
    // nextAlarmDateTime until the nextAlarmDateTime is in the future.
    DateTime now = DateTime.now();

    while (nextAlarmDateTime.isBefore(now)) {
      nextAlarmDateTime = nextAlarmDateTime.add(periodicDuration);
    }

    alarm.lastAlarmTimePurpose = alarm.nextAlarmTime;
    alarm.lastAlarmTimeReal = now;
    alarm.nextAlarmTime = nextAlarmDateTime;
  }

  void addAlarm(Alarm alarm) {
    // Since the user selected the audio file name only, we need to add
    // the path to the assets folder. Path separator must be / and not \
    // since the assets/audio path is defined in the pubspec.yaml file.
    alarm.audioFilePathName = 'audio/${alarm.audioFilePathName}';
    alarms.add(alarm);
    _saveAlarms();

    notifyListeners();
  }

  void editAlarm(Alarm alarm) {
    int index = alarms.indexWhere((element) => element.name == alarm.name);

    if (index == -1) {
      return;
    }

    // Since the user selected the audio file name only, we need to add
    // the path to the assets folder. Path separator must be / and not \
    // since the assets/audio path is defined in the pubspec.yaml file.
    alarm.audioFilePathName = 'audio/${alarm.audioFilePathName}';

    alarms[index] = alarm;
    _saveAlarms();

    notifyListeners();
  }

  void deleteAlarm(int index) {
    alarms.removeAt(index);
    _saveAlarms();

    notifyListeners();
  }

  Future<void> _initializeNotifications() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onClickedNotificationDisplayEditAlarmScreen,
    );
  }

  /// Function called back when the user clicks on a Flutter
  /// local notification. The function opens the edit alarm
  /// sreen.
  Future<void> onClickedNotificationDisplayEditAlarmScreen(
      NotificationResponse response) async {
    // Handle the notification interaction here
    if (response.payload == null || response.payload?.isEmpty == true) {
      return;
    }

    // The payload can be used to identify which Alarm was clicked, and you can call the edit method here
    // For example, if the payload is the name of the alarm:
    Alarm selectedAlarm = alarms.firstWhere((a) => a.name == response.payload);

    navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (context) => SimpleEditAlarmScreen(alarm: selectedAlarm),
    ));
  }

  Future<void> _displayAndroidNotification(Alarm alarm) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'alarm_notif',
      'Alarm Notifications',
      icon: '@mipmap/ic_launcher',
      channelDescription: 'Notifications for Alarm app',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // We will play our own sound using audio player
      ongoing: true,
    );
  }
}
