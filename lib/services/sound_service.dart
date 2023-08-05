// BEGIN: ed8c6549bwf9
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  late AudioPlayer _audioPlayer;

  /// {soundAssetPath} example: 'audio/mixkit-facility-alarm-sound-999.mp3'
  SoundService({
    required String soundAssetPath,
  }) {
    _audioPlayer = AudioPlayer();
    _initializePlayer(
      soundAssetPath: soundAssetPath,
    );
  }

  /// Asset definition in pubspec.yaml
  ///
  ///   assets:
  ///     - assets/audio/
  ///
  void _initializePlayer({
    required String soundAssetPath,
  }) async {
    await _audioPlayer
        .setSourceAsset(soundAssetPath);
  }

  Future<void> playAlarmSound() async {
    await _audioPlayer
        .play(AssetSource('audio/mixkit-facility-alarm-sound-999.mp3'));
  }
}

// END: ed8c6549bwf9