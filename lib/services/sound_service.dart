// BEGIN: ed8c6549bwf9
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  late AudioPlayer _audioPlayer;

  SoundService() {
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  /// Asset definition in pubspec.yaml
  ///
  ///   assets:
  ///     - assets/audio/
  ///
  void _initializePlayer() async {
    await _audioPlayer
        .setSourceAsset('audio/mixkit-facility-alarm-sound-999.mp3');
  }

  Future<void> playAlarmSound() async {
    await _audioPlayer
        .play(AssetSource('audio/mixkit-facility-alarm-sound-999.mp3'));
  }
}

// END: ed8c6549bwf9