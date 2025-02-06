import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class PauseResumeButton extends ConsumerWidget {
  const PauseResumeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(timerStateProvider);
    final toggleTimerUseCase = ref.read(toggleTimerUseCaseProvider);

    return timerStateAsync.when(
      data: (timerState) {
        final isPauseResumeEnabled = timerState.status == TimerStatus.running ||
            timerState.status == TimerStatus.paused;

        return ElevatedButton(
          onPressed:
              isPauseResumeEnabled ? () => toggleTimerUseCase.execute() : null,
          child: Text(
              timerState.status == TimerStatus.paused ? 'Resume' : 'Pause'),
        );
      },
      loading: () => ElevatedButton(
        onPressed: null,
        child: const Text('Pause'),
      ),
      error: (Object error, StackTrace stackTrace) => ElevatedButton(
        onPressed: null,
        child: const Text('Error'),
      ),
    );
  }
}
