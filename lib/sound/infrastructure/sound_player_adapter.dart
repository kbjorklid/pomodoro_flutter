import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';
import 'package:pomodoro_app2/sound/domain/sound_player_port.dart';

class SoundPlayerAdapter implements SoundPlayerPort {
  static final _soundAssetPath = 'assets/sounds/';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playSound(NotificationSound sound) async {
    String soundFile;
    switch (sound) {
      case NotificationSound.chicken:
        soundFile = 'chicken.wav';
        break;
      case NotificationSound.ding:
        soundFile = 'ding.wav';
        break;
      case NotificationSound.gentle:
        soundFile = 'gentle.wav';
        break;
      case NotificationSound.jingle:
        soundFile = 'jingle.wav';
        break;
    }
    String soundPath = '$_soundAssetPath$soundFile';
    await _audioPlayer.play(AssetSource(soundPath));
  }
}
