import 'package:pomodoro_app2/sound/domain/notification_sound.dart';

abstract class SoundPlayerPort {
  Future<void> playSound(NotificationSound sound);
}
