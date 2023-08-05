// BEGIN: ed8c6549bwf9
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static String _soundAssetPath = '';

  /// Asset definition in pubspec.yaml
  ///
  ///   assets:
  ///     - assets/audio/
  ///
  /// {soundAssetPath} example: 'audio/mixkit-facility-alarm-sound-999.mp3'
  void setSoundAssetPath({
    required String soundAssetPath,
  }) async {
    _soundAssetPath = soundAssetPath;
    await _audioPlayer.setSourceAsset(soundAssetPath);
  }

  Future<void> playAlarmSound() async {
    await _audioPlayer
        .play(AssetSource(_soundAssetPath));
  }
}

// END: ed8c6549bwf9