import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class StartPauseButton extends ConsumerWidget {
  const StartPauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Directly watch the TimerState
    final timerState = ref.watch(timerStateProvider);

    // Read the toggleUseCase
    final toggleUseCase = ref.read(toggleTimerUseCaseProvider);

    return ElevatedButton(
      onPressed: () => toggleUseCase.execute(),
      child: Text(_label(timerState.status)),
    );
  }

  String _label(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return 'Pause';
      case TimerStatus.ended:
        return 'Restart';
      case TimerStatus
            .paused: // Add this case. Without this, an error can occur
        return 'Resume';
      default:
        return 'Start';
    }
  }
}