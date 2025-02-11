import 'package:flutter/material.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';

typedef SettingsChangedCallback = void Function();

abstract class SettingsRepositoryPort {
  void addListener(SettingsChangedCallback listener);

  void removeListener(SettingsChangedCallback listener);

  Future<Duration> getWorkDuration();
  Future<void> setWorkDuration(Duration duration);
  
  Future<Duration> getShortRestDuration();
  Future<void> setShortRestDuration(Duration duration);

  Future<Duration> getLongRestDuration();
  Future<void> setLongRestDuration(Duration duration);

  Future<NotificationSound> getTimerEndSound();
  Future<void> setTimerEndSound(NotificationSound sound);

  Future<bool> isPauseEnabled();
  Future<void> setPauseEnabled(bool enabled);

  Future<TimeOfDay> getTypicalWorkDayStart();

  Future<void> setTypicalWorkDayStart(TimeOfDay time);

  Future<Duration> getTypicalWorkDayLength();

  Future<void> setTypicalWorkDayLength(Duration duration);

  Future<bool> isAlwaysShowWorkdayTimespanInTimeline();
  Future<void> setAlwaysShowWorkdayTimespanInTimeline(bool alwaysShow);
}
