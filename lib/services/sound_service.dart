import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _soundAssetPath = '';

  /// Asset definition in pubspec.yaml
  ///
  ///   assets:
  ///     - assets/audio/
  ///
  /// {soundAssetPath} example: 'audio/Lioresal.mp3'
  Future<void> setSoundAssetPath({
    required String soundAssetPath,
  })  async {
    await _audioPlayer.setSourceAsset(soundAssetPath);
    // does not avoid errors [ERROR:flutter/runtime/dart_vm_initializer.cc(41)]
    // Unhandled Exception: Bad state: Future already completed
  }

  Future<void> playAlarmSound({
    required String soundAssetPath,
  } ) async {
    await _audioPlayer
        .play(AssetSource(soundAssetPath));
  }
}
