import 'package:flutter/material.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository implements SettingsRepositoryPort {
  static const _workDurationKey = 'work_duration';
  static const _shortRestDurationKey = 'short_rest_duration';
  static const _longRestDurationKey = 'long_rest_duration';
  static const _selectedSoundKey = 'selected_sound';
  static const _pauseEnabledKey = 'pause_enabled';
  static const _typicalWorkDayStartKey = 'typical_workday_start';
  static const _typicalWorkDayLengthKey = 'typical_workday_length';
  static const _alwaysShowWorkdayTimespanInTimelineKey = 'always_show_workday_timespan_in_timeline';

  static const _defaultWorkDuration = Duration(minutes: 25);
  static const _defaultShortRestDuration = Duration(minutes: 5);
  static const _defaultLongRestDuration = Duration(minutes: 15);
  static const bool _defaultPauseEnabled = true;
  static final _defaultTypicalWorkDayStart = TimeOfDay(hour: 8, minute: 0);
  static final _defaultTypicalWorkDayLength = Duration(hours: 8);
  static const bool _defaultAlwaysShowWorkdayTimespanInTimeline = false;

  @override
  Future<Duration> getWorkDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_workDurationKey);
    return seconds != null 
        ? Duration(seconds: seconds)
        : _defaultWorkDuration;
  }

  @override
  Future<NotificationSound> getTimerEndSound() async {
    final prefs = await SharedPreferences.getInstance();
    final soundName = prefs.getString(_selectedSoundKey);
    if (soundName == null) {
      return NotificationSound.ding;
    }
    return NotificationSound.fromName(soundName);
  }

  @override
  Future<void> setTimerEndSound(NotificationSound sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSoundKey, sound.name);
  }

  @override
  Future<void> setWorkDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workDurationKey, duration.inSeconds);
  }

  @override
  Future<Duration> getShortRestDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_shortRestDurationKey);
    return seconds != null ? Duration(seconds: seconds) : _defaultShortRestDuration;
  }

  @override
  Future<void> setShortRestDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shortRestDurationKey, duration.inSeconds);
  }

  @override
  Future<Duration> getLongRestDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_longRestDurationKey);
    return seconds != null
        ? Duration(seconds: seconds)
        : _defaultLongRestDuration;
  }

  @override
  Future<void> setLongRestDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_longRestDurationKey, duration.inSeconds);
  }

  @override
  Future<bool> isPauseEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pauseEnabledKey) ?? _defaultPauseEnabled;
  }

  @override
  Future<void> setPauseEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pauseEnabledKey, enabled);
  }

  @override
  Future<TimeOfDay> getTypicalWorkDayStart() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_typicalWorkDayStartKey);
    if (timeString == null) {
      return _defaultTypicalWorkDayStart;
    }
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Future<void> setTypicalWorkDayStart(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _typicalWorkDayStartKey, '${time.hour}:${time.minute}');
  }

  @override
  Future<Duration> getTypicalWorkDayLength() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_typicalWorkDayLengthKey);
    return seconds != null
        ? Duration(seconds: seconds)
        : _defaultTypicalWorkDayLength;
  }

  @override
  Future<void> setTypicalWorkDayLength(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_typicalWorkDayLengthKey, duration.inSeconds);
  }

  @override
  Future<bool> isAlwaysShowWorkdayTimespanInTimeline() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alwaysShowWorkdayTimespanInTimelineKey) ?? _defaultAlwaysShowWorkdayTimespanInTimeline;
  }

  @override
  Future<void> setAlwaysShowWorkdayTimespanInTimeline(bool alwaysShow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alwaysShowWorkdayTimespanInTimelineKey, alwaysShow);
  }
}
