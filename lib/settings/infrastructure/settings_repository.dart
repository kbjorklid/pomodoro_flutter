import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';

class SettingsRepository implements SettingsRepositoryPort {
  static const _workDurationKey = 'work_duration';
  static const _restDurationKey = 'rest_duration';
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
