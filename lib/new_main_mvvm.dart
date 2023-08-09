import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

const String appName = "Alarm Manager Example";

// adding method HHmm which returns the Duration formatted as HH:mm

extension FormattedDayHourMinute on Duration {
  static final NumberFormat numberFormatTwoInt = NumberFormat('00');

  // ignore: non_constant_identifier_names

  /// Returns the Duration formatted as HH:mm.
  ///
  /// This method is added to the Duration class by the extension
  /// FormattedDayHourMinute class located in date_time_parser.dart.
  String HHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';

    if (inMinutes < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  /// Returns the Duration formatted as dd:HH:mm
  ///
  /// This method is added to the Duration class by the extension
  /// FormattedDayHourMinute class located in date_time_parser.dart.
  String ddHHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';
    int durationHour =
        Duration(minutes: (inMinutes - durationMinute)).inHours.remainder(24);
    int durationDay = Duration(hours: (inHours - durationHour)).inDays;

    if (inMinutes < 0) {
      minusStr = '-';
    }

    return "$minusStr${numberFormatTwoInt.format(durationDay.abs())}:${numberFormatTwoInt.format(durationHour.abs())}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }
}

class DateTimeParser {
  static DateFormat englishDateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static DateFormat englishDateTimeFormatWithSec = DateFormat("yyyy-MM-dd HH:mm:ss");
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
    print(
        "*** Periodic Task Running for alarm ID 1. Time is ${DateTime.now()}");
    soundServices[1]!.playAlarmSound();
  }

  static void periodicTaskCallbackFunctionLioresal() {
    print(
        "*** Periodic Task Running for alarm ID 2. Time is ${DateTime.now()}");
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
    DateTime truncatedDateTimeToMinute =
        DateTimeParser.truncateDateTimeToMinute(
      DateTime.now().add(
        duration,
      ),
    );

    print(
        "********** SET alarmId: $id\n********** startAlarmHHmm: ${DateTimeParser.englishDateTimeFormatWithSec.format(truncatedDateTimeToMinute)}\n********** alarmHHmmPeriodicity: ${duration.HHmm()}\n********** soundPath: ${soundServices[id]!.soundPath}");
    await AndroidAlarmManager.periodic(
      duration,
      id,
      periodicTaskCallbackFunctions[id]!,
      startAt: truncatedDateTimeToMinute,
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
                duration: const Duration(minutes: 5),
                id: 1,
              );
            },
            child: const Text('Set Alarm 1 (5 minutes, sound 1)'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _alarmService.schedulePeriodicAlarm(
                duration: const Duration(minutes: 7),
                id: 2,
              );
            },
            child: const Text('Set Alarm 2 (7 minutes, sound 2)'),
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
