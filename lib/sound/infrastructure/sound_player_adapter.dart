import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';
import 'package:pomodoro_app2/sound/domain/sound_player_port.dart';

class SoundPlayerAdapter implements SoundPlayerPort {
  static final _soundAssetPath = 'sounds/';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playSound(NotificationSound sound) async {
    String soundFile = '${sound.name}.wav';
    String soundPath = '$_soundAssetPath$soundFile';
    // This produces an error message that cannot be avoided
    // https://github.com/bluefireteam/audioplayers/issues/1635
    await _audioPlayer.play(AssetSource(soundPath));
  }
}
