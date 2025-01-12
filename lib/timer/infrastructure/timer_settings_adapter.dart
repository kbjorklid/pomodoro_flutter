import 'package:pomodoro_app2/timer/domain/timer_settings_port.dart';

class TimerSettingsAdapter implements TimerSettingsPort {
  @override
  int get workDurationSeconds => 25 * 60;

  @override
  int get restDurationSeconds => 5 * 60;
}
