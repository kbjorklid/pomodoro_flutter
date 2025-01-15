import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_app2/sound/domain/sound.dart';
import 'package:pomodoro_app2/sound/domain/sound_player_port.dart';

class SoundPlayerAdapter implements SoundPlayerPort {
  static final _soundAssetPath = 'assets/sounds/';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playSound(Sound sound) async {
    String soundFile;
    switch (sound) {
      case Sound.chicken:
        soundFile = 'chicken.wav';
        break;
      case Sound.ding:
        soundFile = 'ding.wav';
        break;
      case Sound.gentle:
        soundFile = 'gentle.wav';
        break;
      case Sound.jingle:
        soundFile = 'jingle.wav';
        break;
    }
    String soundPath = '$_soundAssetPath$soundFile';
    await _audioPlayer.play(AssetSource(soundPath));
  }
}
