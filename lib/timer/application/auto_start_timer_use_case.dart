import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart'; // Import the port
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart'; // Added import
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
    if (!autoSwitchEnabled) {
      return; // Don't proceed if auto-switch is disabled
    }

    final currentState = _timerNotifier.getCurrentState();
    // Only proceed if there's a current state and it's ready to be started
    if (currentState == null || currentState.status != TimerStatus.notStarted) {
      return;
    }

    bool shouldAutoStart = false;
    // Check which setting to use based on the type of the *next* timer
    if (currentState.timerType == TimerType.shortRest ||
        currentState.timerType == TimerType.longRest) {
      shouldAutoStart = await _settingsRepository.isAutoStartRestEnabled();
    } else if (currentState.timerType == TimerType.work) {
      shouldAutoStart = await _settingsRepository.isAutoStartWorkEnabled();
    }

    // Start the timer only if the relevant auto-start setting is enabled
    if (shouldAutoStart) {
      _timerNotifier.startTimer();
    }
  }
}
