import 'package:audioplayers/audioplayers.dart';

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
  void setSoundAssetPath({
    required String soundAssetPath,
  }) async {
    // await _audioPlayer.setSourceAsset(soundAssetPath);
  }

  Future<void> playAlarmSound() async {
    await _audioPlayer
        .play(AssetSource('audio/mixkit-facility-alarm-sound-999.mp3'));
  }
}
