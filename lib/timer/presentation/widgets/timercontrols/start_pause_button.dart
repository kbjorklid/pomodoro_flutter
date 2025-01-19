import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class StartPauseButton extends ConsumerWidget {
  const StartPauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final timerStateAsync = ref.watch(timerStateProvider);
    final toggleUseCase = ref.read(toggleTimerUseCaseProvider);

    return timerStateAsync.when(
        data: (timerState) {
          return ElevatedButton(
            onPressed: () => toggleUseCase.execute(),
            child: Text(_label(timerState.status)),
          );
        },
        error: (error, stack) => const Text('Error loading timer state'),
        loading: () => Text('Start')
    );
  }

  String _label(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return 'Pause';
      case TimerStatus.ended:
        return 'Restart';
      default:
        return 'Start';
    }
  }
}
