import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/timer/domain/timer_settings_port.dart';

class TimerSettingsAdapter implements TimerSettingsPort {
  final SettingsRepositoryPort _repository;

  TimerSettingsAdapter(this._repository);

  @override
  Future<int> get workDurationSeconds async {
    final duration = await _repository.getWorkDuration();
    return duration.inSeconds;
  }

  @override
  Future<int> get restDurationSeconds async {
    final duration = await _repository.getRestDuration();
    return duration.inSeconds;
  }
}
