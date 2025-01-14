import 'package:pomodoro_app2/timer/domain/sound.dart';

abstract class SoundPlayerPort {
  Future<void> playSound(Sound sound);
}
