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
    // await _audioPlayer.setSourceAsset(soundAssetPath);
  }

  Future<void> playAlarmSound({
    required String soundAssetPath,
  } ) async {
    await _audioPlayer
        .play(AssetSource(soundAssetPath));
  }
}
