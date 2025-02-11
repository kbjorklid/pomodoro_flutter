import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class PauseResumeButton extends ConsumerWidget {
  const PauseResumeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Directly watch the TimerState
    final timerState = ref.watch(timerStateProvider);

    // Read the toggleTimerUseCase
    final toggleTimerUseCase = ref.read(toggleTimerUseCaseProvider);

    // Determine if the button should be enabled
    final isPauseResumeEnabled = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;

    return ElevatedButton(
      onPressed:
          isPauseResumeEnabled ? () => toggleTimerUseCase.execute() : null,
      child: Text(
        timerState.status == TimerStatus.paused ? 'Resume' : 'Pause',
      ),
    );
  }
}