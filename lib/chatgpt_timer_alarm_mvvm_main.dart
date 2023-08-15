// Flutter MVVM Alarm App
// https://chat.openai.com/share/123e52e0-ccdc-4087-9c4d-409366372116

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => AlarmViewModel(),
        child: const MyApp(),
      ),
    );

class DateTimeParser {
  static DateFormat englishDateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static DateFormat englishDateTimeFormatWithSec =
      DateFormat("yyyy-MM-dd HH:mm:ss");
  static DateFormat frenchDateTimeFormat = DateFormat("dd-MM-yyyy HH:mm");
  static DateFormat HHmmDateTimeFormat = DateFormat("HH:mm");

  /// Examples: 2021-01-01T10:35 --> 2021-01-01T11:00
  ///           2021-01-01T10:25 --> 2021-01-01T10:00
  static DateTime roundDateTimeToHour(DateTime dateTime) {
    if (dateTime.minute >= 30) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour + 1, 0, 0, 0, 0);
    } else {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour, 0, 0, 0, 0);
    }
  }

  /// This method takes a DateTime object as input and returns a new DateTime
  /// object with the same year, month, day, hour, and minute as the input,
  /// but with seconds and milliseconds set to zero. Essentially, it rounds
  /// the input DateTime object down to the nearest minute.
  static DateTime truncateDateTimeToMinute(DateTime dateTime) {
    return DateTimeParser.englishDateTimeFormat
        .parse(DateTimeParser.englishDateTimeFormat.format(dateTime));
  }
}

class Alarm {
  String name;
  DateTime nextAlarmTime;
  Duration periodicDuration;
  String audioFilePath;

  // State of the alarm audio

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  set isPlaying(bool isPlaying) {
    _isPlaying = isPlaying;
    _isPaused = false;
  }

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  // AudioPlayer of the current alarm. Enables to play, pause, stop
  // the alarm audio. It is initialized when the alarm audio is
  // played for the first time.
  AudioPlayer? audioPlayer;

  Alarm({
    required this.name,
    required this.nextAlarmTime,
    required this.periodicDuration,
    required this.audioFilePath,
  });

  // Convertir un Alarme à partir de et vers un objet Map (pour la sérialisation JSON)
  Map<String, dynamic> toJson() => {
        'name': name,
        'nextAlarmTime': nextAlarmTime.toIso8601String(),
        'periodicDurationSeconds': periodicDuration.inSeconds,
        'audioFilePath': audioFilePath,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
        name: json['name'],
        nextAlarmTime: DateTime.parse(json['nextAlarmTime']),
        periodicDuration: Duration(seconds: json['periodicDurationSeconds']),
        audioFilePath: json['audioFilePath'],
      );

  void invertPaused() {
    _isPaused = !_isPaused;
  }
}

class AudioPlayerVM extends ChangeNotifier {
  /// Play an audio file located in the assets folder.
  ///
  /// Example: audioFilePath = 'audio/Sirdalud.mp3' if
  /// the audio file is located in the assets/audio folder.
  Future<void> playFromAssets(Alarm alarm) async {
    final file = File(alarm.audioFilePath);

    if (!await file.exists()) {
      print('File not found: ${alarm.audioFilePath}');
    }

    AudioPlayer? audioPlayer = alarm.audioPlayer;

    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
      alarm.audioPlayer = audioPlayer;
    }

    await audioPlayer.play(AssetSource(alarm.audioFilePath));
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

class AlarmViewModel with ChangeNotifier {
  List<Alarm> alarms = [];
  late Timer timer;

  FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  AudioPlayerVM audioPlayerVM = AudioPlayerVM();

  AlarmViewModel() {
    _loadAlarms();
    _initializeNotifications();

    timer = Timer.periodic(const Duration(minutes: 1), _checkAlarms);
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

  Future<void> _checkAlarms(Timer t) async {
    // Vérifiez si une alarme doit être déclenchée

    bool wasAlarnModified = false;

    DateTime now = DateTime.now();

    for (Alarm alarm in alarms) {
      if (alarm.nextAlarmTime.isBefore(now)) {
        _triggerNotification(alarm);
        await audioPlayerVM.playFromAssets(alarm);

        // Update the nextAlarmTime
        alarm.nextAlarmTime = DateTimeParser.truncateDateTimeToMinute(now)
            .add(alarm.periodicDuration);
        wasAlarnModified = true;
      }
    }

    if (wasAlarnModified) {
      _saveAlarms();

      notifyListeners();
    }
  }

  addAlarm(Alarm alarm) {
    // Since the user entered the audio file name only, we need to add
    // the path to the assets folder. Path separator must be / and not \
    // since the assets/audio path is defined in the pubspec.yaml file.
    alarm.audioFilePath = 'audio/${alarm.audioFilePath}';
    alarms.add(alarm);
    _saveAlarms();

    notifyListeners();
  }

  deleteAlarm(int index) {
    alarms.removeAt(index);
    _saveAlarms();

    notifyListeners();
  }

  _initializeNotifications() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await localNotifications.initialize(initializationSettings);
  }

  Future<void> _triggerNotification(Alarm alarm) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'alarm_notif',
      'Alarm Notifications',
      icon: '@mipmap/ic_launcher',
      channelDescription: 'Notifications for Alarm app',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // We will play our own sound using audio player
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotifications.show(
      0, // ID
      'Alarm Triggered',
      'Alarm: ${alarm.name} has been triggered!',
      platformChannelSpecifics,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Alarm App',
      home: AlarmPage(),
    );
  }
}

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  void initState() {
    requestMultiplePermissions();
    super.initState();
  }

  void requestMultiplePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission
          .manageExternalStorage, // Android 11 (API level 30) or higher only
      Permission.microphone,
      Permission.mediaLibrary,
      Permission.speech,
      Permission.audio,
      Permission.videos,
      Permission.notification
    ].request();

    // Vous pouvez maintenant vérifier l'état de chaque permission
    if (!statuses[Permission.storage]!.isGranted ||
        !statuses[Permission.manageExternalStorage]!.isGranted ||
        !statuses[Permission.microphone]!.isGranted ||
        !statuses[Permission.mediaLibrary]!.isGranted ||
        !statuses[Permission.speech]!.isGranted ||
        !statuses[Permission.audio]!.isGranted ||
        !statuses[Permission.videos]!.isGranted ||
        !statuses[Permission.notification]!.isGranted) {
      // Une ou plusieurs permissions n'ont pas été accordées.
      // Vous pouvez désactiver les fonctionnalités correspondantes dans
      // votre application ou montrer une alerte à l'utilisateur.
    } else {
      // Toutes les permissions ont été accordées, vous pouvez continuer avec
      // vos fonctionnalités.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestionnaire d'alarmes")),
      body: Consumer<AlarmViewModel>(
        builder: (context, viewModel, child) => ListView.builder(
          itemCount: viewModel.alarms.length,
          itemBuilder: (context, index) {
            final alarm = viewModel.alarms[index];
            return ListTile(
              title: Text(alarm.name),
              subtitle: Text(
                  'Prochaine alarme: ${DateTimeParser.frenchDateTimeFormat.format(alarm.nextAlarmTime)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => viewModel.deleteAlarm(index),
              ),
              onTap: () {
                _showEditAlarmDialog(alarm);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Alarm? newAlarm = await _showAddAlarmDialog(context);
          if (newAlarm != null) {
            // Assuming you have a method in your ViewModel to add alarms
            Provider.of<AlarmViewModel>(context, listen: false)
                .addAlarm(newAlarm);
          }
        },
      ),
    );
  }

  Future<Alarm?> _showAddAlarmDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController timeController = TextEditingController(
        text: DateTimeParser.HHmmDateTimeFormat.format(
            DateTimeParser.truncateDateTimeToMinute(
                DateTime.now()))); // For simplicity, you can use "hh:mm" format
    TextEditingController durationController =
        TextEditingController(); // Again, use "hh:mm" format
    TextEditingController audioFileController = TextEditingController();

    return showDialog<Alarm>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Alarm'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(
                      labelText: 'Next Alarm Time (hh:mm)'),
                ),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                      labelText: 'Resilient Duration (hh:mm)'),
                ),
                TextFormField(
                  controller: audioFileController,
                  decoration: const InputDecoration(
                      labelText: 'Audio File Name (e.g., Flutter.mp3)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Process the input values and create a new Alarm instance
                final name = nameController.text;
                final nextAlarmTime = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    int.parse(timeController.text.split(':')[0]),
                    int.parse(timeController.text.split(':')[1]));
                final resilientDuration = Duration(
                  hours: int.parse(durationController.text.split(':')[0]),
                  minutes: int.parse(durationController.text.split(':')[1]),
                );
                final audioFileName = audioFileController.text;
                Navigator.of(context).pop(Alarm(
                    name: name,
                    nextAlarmTime: nextAlarmTime,
                    periodicDuration: resilientDuration,
                    audioFilePath: audioFileName));
              },
            ),
          ],
        );
      },
    );
  }

  _showEditAlarmDialog(Alarm alarm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alarm Triggered!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${alarm.name}'),
              Text('Next Alarm Time: ${alarm.nextAlarmTime}'),
              // Add more details as required
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                // Navigate to the edit page or display another dialog
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
