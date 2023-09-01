// Flutter MVVM Alarm App
// https://chat.openai.com/share/123e52e0-ccdc-4087-9c4d-409366372116

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const double kFontSize = 17;
const double kLabelStyleFontSize = 25;

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AlarmVM(),
    child: const MyApp(),
  ));

  BackgroundFetch.registerHeadlessTask(
    AlarmVM().checkAlarmsPeriodically,
  );
}

class DateTimeParser {
  static DateFormat englishDateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static DateFormat englishDateTimeFormatWithSec =
      DateFormat("yyyy-MM-dd HH:mm:ss");
  static DateFormat frenchDateTimeFormat = DateFormat("dd-MM-yyyy HH:mm");
  static DateFormat HHmmDateTimeFormat = DateFormat("HH:mm");

  /// Examples: kFontSize21-01-01T10:35 --> kFontSize21-01-01T11:00
  ///           kFontSize21-01-01T10:25 --> kFontSize21-01-01T10:00
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

  /// Method used to format the entered string duration
  /// to the duration TextField format, either HH:mm or
  /// dd:HH:mm. The method enables entering an int
  /// duration value instead of an HH:mm duration. For
  /// example, 2 or 24 instead of 02:00 or 24:00.
  ///
  /// If the removeMinusSign parm is false, entering -2
  /// converts the duration string to -2:00, which is
  /// useful in the Add dialog accepting adding a positive
  /// or negative duration.
  ///
  /// If dayHourMinuteFormat is true, the returned string
  /// duration for 2 is 00:02:00 or for 3:24 00:03:24.
  ///
  /// This method has been extracted from utils/utility.dart
  /// in circa_plan project in which the method is unit
  /// tested.
  static String formatStringDuration({
    required String durationStr,
    bool removeMinusSign = true,
    bool dayHourMinuteFormat = false,
  }) {
    if (removeMinusSign) {
      durationStr = durationStr.replaceAll(RegExp(r'[+\-]+'), '');
    } else {
      durationStr = durationStr.replaceAll(RegExp(r'[+]+'), '');
    }

    if (dayHourMinuteFormat) {
      // the case if used on TimeCalculator screen
      int? durationInt = int.tryParse(durationStr);

      if (durationInt != null) {
        if (durationInt < 0) {
          if (durationInt > -10) {
            durationStr = '-00:0${durationInt * -1}:00';
          } else {
            durationStr = '-00:${durationInt * -1}:00';
          }
        } else {
          if (durationInt < 10) {
            durationStr = '00:0$durationStr:00';
          } else {
            durationStr = '00:$durationStr:00';
          }
        }
      } else {
        RegExp re = RegExp(r"^\d+:\d{1}$");
        RegExpMatch? match = re.firstMatch(durationStr);
        if (match != null) {
          durationStr = '${match.group(0)}0';
        } else {
          if (!removeMinusSign) {
            RegExp re = RegExp(r"^-\d+:\d{1}$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = '${match.group(0)}0';
            }
          }
        }
      }

      RegExp re = RegExp(r"^\d{1}:\d+$");
      RegExpMatch? match = re.firstMatch(durationStr);

      if (match != null) {
        durationStr = '00:0${match.group(0)}';
      } else {
        RegExp re = RegExp(r"^\d{2}:\d+$");
        RegExpMatch? match = re.firstMatch(durationStr);
        if (match != null) {
          durationStr = '00:${match.group(0)}';
        } else {
          RegExp re = RegExp(r"^\d{1}:\d{2}:\d+$");
          RegExpMatch? match = re.firstMatch(durationStr);
          if (match != null) {
            durationStr = '0${match.group(0)}';
          } else {
            RegExp re = RegExp(r"^\d{2}:\d{2}:\d+$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = '${match.group(0)}';
            }
          }
        }
      }
    } else {
      int? durationInt = int.tryParse(durationStr);

      if (durationInt != null) {
        // the case if a one or two digits duration was entered ...
        durationStr = '$durationStr:00';
      } else {
        RegExp re = RegExp(r"^\d+:\d{1}$");
        RegExpMatch? match = re.firstMatch(durationStr);
        if (match != null) {
          durationStr = '${match.group(0)}0';
        } else {
          if (!removeMinusSign) {
            RegExp re = RegExp(r"^-\d+:\d{1}$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = '${match.group(0)}0';
            }
          } else {
            // the case when copying a 00:hh:mm time text field content to a
            // duration text field.
            RegExp re = RegExp(r"^00:\d{2}:\d{2}$");
            RegExpMatch? match = re.firstMatch(durationStr);
            if (match != null) {
              durationStr = match.group(0)!.replaceFirst('00:', '');
            }
          }
        }
      }
    }

    return durationStr;
  }

  /// If the input HH:mm time string is before now, the method
  /// returns a DateTime object with the same time but tomorrow.
  static DateTime computeNextAlarmDateTime({
    required String formattedHhMmNextAlarmTimeStr,
  }) {
    int nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
    int nextAlarmMinutes =
        int.parse(formattedHhMmNextAlarmTimeStr.split(':')[0]) * 60 +
            int.parse(formattedHhMmNextAlarmTimeStr.split(':')[1]);

    if (nextAlarmMinutes <= nowMinutes) {
      return DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          int.parse(formattedHhMmNextAlarmTimeStr.split(':')[0]),
          int.parse(formattedHhMmNextAlarmTimeStr.split(':')[1]));
    }

    return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(formattedHhMmNextAlarmTimeStr.split(':')[0]),
        int.parse(formattedHhMmNextAlarmTimeStr.split(':')[1]));
  }
}

class Alarm {
  String name;

  // last time the alarm should have been triggered
  DateTime? lastAlarmTimePurpose;

  // last time the alarm has been triggered
  DateTime? lastAlarmTimeReal;

  // next time the alarm will be triggered
  DateTime nextAlarmTime;

  Duration periodicDuration;

  // for example, 'audio/alarm.mp3'
  String audioFilePathName;

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
    this.lastAlarmTimePurpose,
    this.lastAlarmTimeReal,
    required this.nextAlarmTime,
    required this.periodicDuration,
    required this.audioFilePathName,
  });

  // Convertir un Alarme à partir de et vers un objet Map (pour la sérialisation JSON)
  Map<String, dynamic> toJson() => {
        'name': name,
        'lastAlarmTimePurpose': lastAlarmTimePurpose?.toIso8601String(),
        'lastAlarmTimeReal': lastAlarmTimeReal?.toIso8601String(),
        'nextAlarmTime': nextAlarmTime.toIso8601String(),
        'periodicDurationSeconds': periodicDuration.inSeconds,
        'audioFilePathName': audioFilePathName,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
        name: json['name'],
        lastAlarmTimePurpose: json['lastAlarmTimePurpose'] != null
            ? DateTime.parse(json['lastAlarmTimePurpose'])
            : null,
        lastAlarmTimeReal: json['lastAlarmTimeReal'] != null
            ? DateTime.parse(json['lastAlarmTimeReal'])
            : null,
        nextAlarmTime: DateTime.parse(json['nextAlarmTime']),
        periodicDuration: Duration(seconds: json['periodicDurationSeconds']),
        audioFilePathName: json['audioFilePathName'],
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
    final file = File(alarm.audioFilePathName);

    if (!await file.exists()) {
      print('File not found: ${alarm.audioFilePathName}');
    }

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

  static const int alarmCheckingMinutes = 3;

  static final AlarmVM _singleton = AlarmVM._internal();

  factory AlarmVM() {
    return _singleton;
  }

  AlarmVM._internal() {
    _loadAlarms();
    _initializeNotifications();
  }

  // AlarmVM() {
  //   _loadAlarms();
  //   _initializeNotifications();

  //   timer = Timer.periodic(
  //       const Duration(minutes: alarmCheckingMinutes), checkAlarmsPeriodically);
  // }

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
        alarm.lastAlarmTimePurpose = alarm.nextAlarmTime;
        alarm.lastAlarmTimeReal = now;
        alarm.nextAlarmTime = alarm.nextAlarmTime.add(alarm.periodicDuration);
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

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // ID
      'Alarm Triggered',
      'Alarm: ${alarm.name} has been triggered!',
      platformChannelSpecifics,
      payload: alarm.name, // This is used to identify which alarm was triggered
    );
  }
}

class SimpleEditAlarmScreen extends StatefulWidget {
  final Alarm alarm;

  const SimpleEditAlarmScreen({super.key, required this.alarm});

  @override
  _SimpleEditAlarmScreenState createState() => _SimpleEditAlarmScreenState(
        alarm: alarm,
      );
}

class _SimpleEditAlarmScreenState extends State<SimpleEditAlarmScreen> {
  final Alarm _alarm;

  _SimpleEditAlarmScreenState({
    required Alarm alarm,
  }) : _alarm = alarm;

  // Your simple edit logic here, maybe just a few key fields rather than everything.
  @override
  void initState() {
    super.initState();

    // Set the value of the dropdown button menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlarmVM>(context, listen: false).selectedAudioFile =
          _alarm.audioFilePathName.split('/').last;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: _alarm.name);
    TextEditingController timeController = TextEditingController(
        text: DateTimeParser.HHmmDateTimeFormat.format(_alarm.nextAlarmTime));
    TextEditingController durationController = TextEditingController(
        text:
            "${_alarm.periodicDuration.inHours.toString().padLeft(2, '0')}:${(_alarm.periodicDuration.inMinutes % 60).toString().padLeft(2, '0')}");

    List<Widget> alarmEditionWidgetLst = createAlarmEditionWidgetLst(
      nameController: nameController,
      timeController: timeController,
      periodicityDurationController: durationController,
      isNextAlarmClearButtonDisplayed: true,
      isPeriodicityClearButtonDisplayed: true,
    );

    alarmEditionWidgetLst.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save Changes'),
          onPressed: () {
            // Update the current alarm's details
            _alarm.name = nameController.text;

            // enabling the user to enter a next alarm time in a
            // simplified format (e.g. 9:3 for 09:30 or 15 for
            // 15:00.
            final String formattedHhMmNextAlarmTimeStr =
                DateTimeParser.formatStringDuration(
              durationStr: timeController.text,
            );

            _alarm.nextAlarmTime = DateTimeParser.computeNextAlarmDateTime(
              formattedHhMmNextAlarmTimeStr: formattedHhMmNextAlarmTimeStr,
            );

            // enabling the user to enter a periodicity in a
            // simplified format (e.g. 1:30 for 01:30 or 5 for
            // 05:00.
            final String formattedHhMmPeriodicityStr =
                DateTimeParser.formatStringDuration(
              durationStr: durationController.text,
            );
            _alarm.periodicDuration = Duration(
              hours: int.parse(formattedHhMmPeriodicityStr.split(':')[0]),
              minutes: int.parse(formattedHhMmPeriodicityStr.split(':')[1]),
            );

            AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
            _alarm.audioFilePathName = alarmVM.selectedAudioFile;
            alarmVM.editAlarm(_alarm);

            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Alarm"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: alarmEditionWidgetLst,
        ),
      ),
    );
  }
}

List<Widget> createAlarmEditionWidgetLst({
  required TextEditingController nameController,
  required TextEditingController timeController,
  required TextEditingController periodicityDurationController,
  bool isNextAlarmClearButtonDisplayed = false,
  bool isPeriodicityClearButtonDisplayed = false,
}) {
  List<Widget> alarmEditionWidgetLst = [];

  alarmEditionWidgetLst.add(TextFormField(
    controller: nameController,
    decoration: const InputDecoration(
      labelText: 'Name',
      labelStyle: TextStyle(
        fontSize: kLabelStyleFontSize,
      ),
    ),
    style: const TextStyle(
      fontSize: kFontSize,
    ),
  ));
  alarmEditionWidgetLst.add(TextFormField(
    controller: timeController,
    decoration: InputDecoration(
      labelText: 'Next Alarm Time (hh:mm)',
      labelStyle: const TextStyle(
        fontSize: kLabelStyleFontSize,
      ),
      // Add the clear button to the InputDecoration
      suffixIcon: isNextAlarmClearButtonDisplayed
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => timeController.clear(),
            )
          : null,
    ),
    style: const TextStyle(
      fontSize: kFontSize,
    ),
  ));
  alarmEditionWidgetLst.add(TextFormField(
    controller: periodicityDurationController,
    decoration: InputDecoration(
      labelText: 'Periodicity (hh:mm)',
      labelStyle: const TextStyle(
        fontSize: kLabelStyleFontSize,
      ),
      // Add the clear button to the InputDecoration
      suffixIcon: isPeriodicityClearButtonDisplayed
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => periodicityDurationController.clear(),
            )
          : null,
    ),
    style: const TextStyle(
      fontSize: kFontSize,
    ),
  ));
  alarmEditionWidgetLst.add(Consumer<AlarmVM>(
    builder: (context, viewModel, child) => DropdownButton<String>(
      value: viewModel.selectedAudioFile,
      items: AlarmVM.audioFileNames.map((String fileName) {
        return DropdownMenuItem<String>(
          value: fileName,
          child: Text(
            fileName,
            style: const TextStyle(fontSize: kFontSize),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          viewModel.selectedAudioFile = newValue;
        }
      },
    ),
  ));

  return alarmEditionWidgetLst;
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      navigatorKey: navigatorKey,
      home: const AlarmPage(),
    );
  }
}

class AlarmPage extends StatefulWidget {
  const AlarmPage({
    super.key,
  });

  @override
  _AlarmPageState createState() => _AlarmPageState();

  Widget createInfoRowFunction({
    Key? valueTextWidgetKey, // key set to the Text widget displaying the value
    required BuildContext context,
    required String label,
    required String value,
    bool isTextBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: kFontSize,
              fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Text(
            key: valueTextWidgetKey,
            value,
            style: TextStyle(
              fontSize: kFontSize,
              fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  void initState() {
    super.initState();

    _requestMultiplePermissions();

    _initPlatformState();
  }

  void _requestMultiplePermissions() async {
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
      // Toutes les permissions ont été accordées, vous pouvez continuer
      // avec vos fonctionnalités.
    }
  }

  Future<void> _initPlatformState() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      AlarmVM().checkAlarmsPeriodically,
    );

    BackgroundFetch.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alarm Manager")),
      body: Consumer<AlarmVM>(
        builder: (context, viewModel, child) => ListView.builder(
          itemCount: viewModel.alarms.length,
          itemBuilder: (context, index) {
            final alarm = viewModel.alarms[index];
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              child: ListTile(
                title: Text(
                  alarm.name,
                  style: const TextStyle(
                    fontSize: kFontSize,
                  ),
                ),
                subtitle: InkWell(
                  onTap: () {
                    _showEditAlarmDialog(alarm);
                  },
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Aligns the text to the left
                    children: [
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Real alarm: ',
                        value: (alarm.lastAlarmTimeReal == null)
                            ? ''
                            : DateTimeParser.frenchDateTimeFormat
                                .format(alarm.lastAlarmTimeReal!),
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Last alarm: ',
                        value: (alarm.lastAlarmTimePurpose == null)
                            ? ''
                            : DateTimeParser.frenchDateTimeFormat
                                .format(alarm.lastAlarmTimePurpose!),
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Next alarm: ',
                        value: DateTimeParser.frenchDateTimeFormat
                            .format(alarm.nextAlarmTime),
                        isTextBold: true,
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Periodicity:',
                        value:
                            '${alarm.periodicDuration.inHours.toString().padLeft(2, '0')}:${(alarm.periodicDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Audio file:',
                        value: alarm.audioFilePathName.split('/').last,
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => viewModel.deleteAlarm(index),
                ),
                onTap: () {
                  _showEditAlarmDialog(alarm);
                },
              ),
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
            Provider.of<AlarmVM>(context, listen: false).addAlarm(newAlarm);
          }
        },
      ),
    );
  }

  Future<Alarm?> _showAddAlarmDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController timeController = TextEditingController(
        text: DateTimeParser.HHmmDateTimeFormat.format(
            DateTimeParser.truncateDateTimeToMinute(DateTime.now())));
    TextEditingController durationController = TextEditingController();

    // Set the default value of the dropdown button menu
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    alarmVM.selectedAudioFile = AlarmVM.audioFileNames[0];

    List<Widget> alarmEditionWidgetLst = createAlarmEditionWidgetLst(
      nameController: nameController,
      timeController: timeController,
      periodicityDurationController: durationController,
      isNextAlarmClearButtonDisplayed: true,
    );

    return showDialog<Alarm>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Alarm'),
          content: SingleChildScrollView(
            child: Column(
              children: alarmEditionWidgetLst,
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

                // enabling the user to enter a next alarm time in a
                // simplified format (e.g. 9:3 for 09:30 or 15 for
                // 15:00.
                final String formattedHhMmNextAlarmTimeStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: timeController.text,
                );
                final nextAlarmTime = DateTimeParser.computeNextAlarmDateTime(
                  formattedHhMmNextAlarmTimeStr: formattedHhMmNextAlarmTimeStr,
                );

                // enabling the user to enter a periodicity in a
                // simplified format (e.g. 1:3 for 01:30 or 5 for
                // 05:00.
                final String formattedHhMmPeriodicityStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: durationController.text,
                );
                final periodicDuration = Duration(
                  hours: int.parse(formattedHhMmPeriodicityStr.split(':')[0]),
                  minutes: int.parse(formattedHhMmPeriodicityStr.split(':')[1]),
                );

                Navigator.of(context).pop(Alarm(
                    name: name,
                    nextAlarmTime: nextAlarmTime,
                    periodicDuration: periodicDuration,
                    audioFilePathName: alarmVM.selectedAudioFile));
              },
            ),
          ],
        );
      },
    );
  }

  _showEditAlarmDialog(Alarm alarm) {
    TextEditingController nameController =
        TextEditingController(text: alarm.name);
    TextEditingController timeController = TextEditingController(
        text: DateTimeParser.HHmmDateTimeFormat.format(alarm.nextAlarmTime));
    TextEditingController durationController = TextEditingController(
        text:
            "${alarm.periodicDuration.inHours.toString().padLeft(2, '0')}:${(alarm.periodicDuration.inMinutes % 60).toString().padLeft(2, '0')}");

    // Set the value of the dropdown button menu
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    alarmVM.selectedAudioFile = alarm.audioFilePathName.split('/').last;

    List<Widget> alarmEditionWidgetLst = createAlarmEditionWidgetLst(
      nameController: nameController,
      timeController: timeController,
      periodicityDurationController: durationController,
      isNextAlarmClearButtonDisplayed: true,
      isPeriodicityClearButtonDisplayed: true,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Alarm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: alarmEditionWidgetLst,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save Changes'),
              onPressed: () {
                // Update the current alarm's details
                alarm.name = nameController.text;

                // enabling the user to enter a next alarm time in a
                // simplified format (e.g. 9:3 for 09:30 or 15 for
                // 15:00.
                final String formattedHhMmNextAlarmTimeStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: timeController.text,
                );

                alarm.nextAlarmTime = DateTimeParser.computeNextAlarmDateTime(
                  formattedHhMmNextAlarmTimeStr: formattedHhMmNextAlarmTimeStr,
                );

                // enabling the user to enter a periodicity in a
                // simplified format (e.g. 1:3 for 01:30 or 5 for
                // 05:00.
                final String formattedHhMmPeriodicityStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: durationController.text,
                );

                alarm.periodicDuration = Duration(
                  hours: int.parse(formattedHhMmPeriodicityStr.split(':')[0]),
                  minutes: int.parse(formattedHhMmPeriodicityStr.split(':')[1]),
                );
                alarm.audioFilePathName = alarmVM.selectedAudioFile;
                alarmVM.editAlarm(alarm);

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
