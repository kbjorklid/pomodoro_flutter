import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart'; // Import the port
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_start_timer_use_case.g.dart';


@riverpod
AutoStartTimerUseCase autoStartTimerUseCase(Ref ref) {
  final settingsRepository = ref.read(settingsRepositoryProvider);
  final timerNotifier = ref.read(pomodoroTimerProvider.notifier);
  return AutoStartTimerUseCase(settingsRepository, timerNotifier);
}

class AutoStartTimerUseCase {
  final SettingsRepositoryPort _settingsRepository;
  final PomodoroTimer _timerNotifier;

  AutoStartTimerUseCase(this._settingsRepository, this._timerNotifier);

  Future<void> execute() async {
    final autoSwitchEnabled = await _settingsRepository.getAutoSwitchTimer();
    final autoStartEnabled =
        await _settingsRepository.isAutoStartAfterSwitchEnabled();

    if (autoSwitchEnabled && autoStartEnabled) {
      final currentState = _timerNotifier.getCurrentState();
      if (currentState != null &&
          currentState.status == TimerStatus.notStarted) {
        _timerNotifier.startTimer();
      }
    }
  }
}
