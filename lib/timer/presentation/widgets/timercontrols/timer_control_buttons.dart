import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/application/toggle_timer_use_case.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';

abstract class _TimerStateDependentButton extends ConsumerWidget {
  const _TimerStateDependentButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(pomodoroTimerProvider);

    return timerStateAsync.when(
      data: (timerState) => _buildButton(timerState, ref),
      loading: () => const ElevatedButton(
        onPressed: null,
        child: Text('Loading'),
      ),
      error: (error, stackTrace) => const ElevatedButton(
        onPressed: null,
        child: Text('Error'),
      ),
    );
  }

  _buildButton(TimerState timerState, WidgetRef ref);
}

class StartButton extends _TimerStateDependentButton {
  const StartButton({super.key});

  @override
  ElevatedButton _buildButton(timerState, WidgetRef ref) {
    final toggleTimerUseCase = ref.read(toggleTimerUseCaseProvider);
    final isStartEnabled = timerState.status == TimerStatus.notStarted ||
        timerState.status == TimerStatus.ended;
    return ElevatedButton(
      onPressed: isStartEnabled ? () => toggleTimerUseCase.execute() : null,
      child: Text(
        timerState.status == TimerStatus.ended ? 'Restart' : 'Start',
      ),
    );
  }
}

class StopButton extends _TimerStateDependentButton {
  const StopButton({super.key});

  @override
  ElevatedButton _buildButton(timerState, WidgetRef ref) {
    final isStopEnabled = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;
    final PomodoroTimer timer = ref.read(pomodoroTimerProvider.notifier);
    return ElevatedButton(
      onPressed: isStopEnabled ? () => timer.stopTimer() : null,
      child: const Text('Stop'),
    );
  }
}


class PauseResumeButton extends _TimerStateDependentButton {
  const PauseResumeButton({super.key});


  @override
  ElevatedButton _buildButton(timerState, WidgetRef ref) {
    final isPauseResumeEnabled = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;
    final toggleTimerUseCase = ref.read(toggleTimerUseCaseProvider);

    return ElevatedButton(
      onPressed:
      isPauseResumeEnabled ? () => toggleTimerUseCase.execute() : null,
      child: Text(
        timerState.status == TimerStatus.paused ? 'Resume' : 'Pause',
      ),
    );
  }
}