import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class StartButton extends ConsumerWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(timerStateProvider);
    final toggleTimerUseCase = ref.read(toggleTimerUseCaseProvider);

    return timerStateAsync.when(
      data: (timerState) {
        final isStartEnabled = timerState.status == TimerStatus.notStarted ||
            timerState.status == TimerStatus.ended;

        return ElevatedButton(
          onPressed: isStartEnabled ? () => toggleTimerUseCase.execute() : null,
          child: Text(
              timerState.status == TimerStatus.ended ? 'Restart' : 'Start'),
        );
      },
      loading: () => ElevatedButton(
        onPressed: null,
        child: const Text('Start'),
      ),
      error: (error, stackTrace) => ElevatedButton(
        onPressed: null,
        child: const Text('Error'),
      ),
    );
  }
}
