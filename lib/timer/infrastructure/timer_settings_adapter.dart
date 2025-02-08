import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/timer/domain/timer_settings_port.dart';

class TimerSettingsAdapter implements TimerSettingsPort {
  final SettingsRepositoryPort _repository;

  TimerSettingsAdapter(this._repository);

  @override
  Future<Duration> get workDuration => _repository.getWorkDuration();

  @override
  Future<Duration> get shortRestDuration => _repository.getShortRestDuration();

  @override
  Future<Duration> get longRestDuration => _repository.getLongRestDuration();
}
