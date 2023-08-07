import 'package:audioplayers/audioplayers.dart';

class SoundService {
  /// Asset definition in pubspec.yaml
  ///
  ///   assets:
  ///     - assets/audio/
  ///
  /// {soundAssetPath} example: 'audio/Lioresal.mp3'
  Future<void> playAlarmSound({
    required String soundAssetPath,
  } ) async {
    AudioPlayer audioPlayer = AudioPlayer();

    await audioPlayer.setSourceAsset(soundAssetPath);
    await audioPlayer.play(AssetSource(soundAssetPath));
  }
}
