import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';

import 'package:pomodoro_app2/timer/domain/sound.dart';

class SettingsRepository implements SettingsRepositoryPort {
  static const _workDurationKey = 'work_duration';
  static const _restDurationKey = 'rest_duration';
  static const _selectedSoundKey = 'selected_sound';
  static const _defaultWorkDuration = Duration(minutes: 25);
  static const _defaultRestDuration = Duration(minutes: 5);

  @override
  Future<Duration> getWorkDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_workDurationKey);
    return seconds != null 
        ? Duration(seconds: seconds)
        : _defaultWorkDuration;
  }

  @override
  Future<Sound> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    final soundName = prefs.getString(_selectedSoundKey);
    if (soundName == null) {
      return Sound.ding;
    }
    return Sound.values.firstWhere((e) => e.name == soundName, orElse: () => Sound.ding);
  }

  @override
  Future<void> setSelectedSound(Sound sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSoundKey, sound.name);
  }

  @override
  Future<void> setWorkDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workDurationKey, duration.inSeconds);
  }

  @override
  Future<Duration> getRestDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_restDurationKey);
    return seconds != null
        ? Duration(seconds: seconds)
        : _defaultRestDuration;
  }

  @override
  Future<void> setRestDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_restDurationKey, duration.inSeconds);
  }
}
