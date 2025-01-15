import 'package:flutter/foundation.dart';
import 'package:pomodoro_app2/sound/domain/sound.dart';

abstract class SettingsRepositoryPort {
  Future<Duration> getWorkDuration();
  Future<void> setWorkDuration(Duration duration);
  
  Future<Duration> getRestDuration();
  Future<void> setRestDuration(Duration duration);

  Future<Sound> getSelectedSound();
  Future<void> setSelectedSound(Sound sound);
}
