import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _player = AudioPlayer();

  SoundService._internal() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  factory SoundService() => _instance;

  Future<void> playCorrect(double volume) async {
    await _play('sounds/correct.wav', volume);
  }

  Future<void> playWrong(double volume) async {
    await _play('sounds/wrong.wav', volume);
  }

  Future<void> playResult(double volume) async {
    await _play('sounds/congrats.wav', volume);
  }

  Future<void> _play(String assetPath, double volume) async {
    try {
      await _player.play(AssetSource(assetPath), volume: volume);
    } catch (_) {
      // Ignore sound failures so UI continues working.
    }
  }
}
