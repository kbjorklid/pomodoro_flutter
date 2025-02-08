abstract class TimerSettingsPort {
  Future<Duration> get workDuration;
  Future<Duration> get shortRestDuration;
  Future<Duration> get longRestDuration;
}
