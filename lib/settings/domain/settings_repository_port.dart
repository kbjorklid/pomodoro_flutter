import 'package:flutter/material.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';

abstract class SettingsRepositoryPort {
  Future<Duration> getWorkDuration();
  Future<void> setWorkDuration(Duration duration);
  
  Future<Duration> getRestDuration();
  Future<void> setRestDuration(Duration duration);

  Future<NotificationSound> getTimerEndSound();
  Future<void> setTimerEndSound(NotificationSound sound);

  Future<bool> isPauseEnabled();
  Future<void> setPauseEnabled(bool enabled);

  Future<TimeOfDay> getTypicalWorkDayStart();

  Future<void> setTypicalWorkDayStart(TimeOfDay time);

  Future<Duration> getTypicalWorkDayLength();

  Future<void> setTypicalWorkDayLength(Duration duration);
}
