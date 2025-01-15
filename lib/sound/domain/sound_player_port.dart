import 'package:pomodoro_app2/sound/domain/sound.dart';

abstract class SoundPlayerPort {
  Future<void> playSound(Sound sound);
}
