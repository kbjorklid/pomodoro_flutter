import 'package:flutter/material.dart';
import 'package:pomodoro_app2/settings/domain/app_theme_mode.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';
import 'timer_durations.dart';

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

  Future<int?> getDailyPomodoroGoal();
  Future<void> setDailyPomodoroGoal(int? goal);

  Future<TimerDurations> getTimerDurations();

  Future<bool> getAutoSwitchTimer();
  Future<void> setAutoSwitchTimer(bool enabled);

  Future<bool> isAutoStartRestEnabled();
  Future<void> setAutoStartRest(bool enabled);

  Future<bool> isAutoStartWorkEnabled();
  Future<void> setAutoStartWork(bool enabled);

  Future<bool> isAllowOvertimeEnabled();
  Future<void> setAllowOvertime(bool enabled);

  Future<AppThemeMode> getThemeMode();
  Future<void> setThemeMode(AppThemeMode mode);
}
