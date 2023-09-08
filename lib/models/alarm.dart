import 'package:audioplayers/audioplayers.dart';

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

  // Copy constructor
  Alarm.copy({
    required Alarm originalAlarm,
  })  : name = originalAlarm.name,
        lastAlarmTimePurpose = originalAlarm.lastAlarmTimePurpose,
        lastAlarmTimeReal = originalAlarm.lastAlarmTimeReal,
        nextAlarmTime = originalAlarm.nextAlarmTime,
        periodicDuration = originalAlarm.periodicDuration,
        audioFilePathName = originalAlarm.audioFilePathName,
        _isPlaying = originalAlarm._isPlaying,
        _isPaused = originalAlarm._isPaused,
        audioPlayer = originalAlarm.audioPlayer != null
            ? AudioPlayer(playerId: originalAlarm.audioPlayer!.playerId)
            : null;

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
