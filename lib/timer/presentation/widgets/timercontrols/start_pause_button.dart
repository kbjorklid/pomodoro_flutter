import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class StartPauseButton extends ConsumerWidget {
  const StartPauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final timerStateAsync = ref.watch(timerStateProvider);
    final timerService = ref.read(timerProvider);

    return timerStateAsync.when(
        data: (timerState) {
          return ElevatedButton(
            onPressed: timerService.startTimerOrPause,
            child: Text(timerState.status == TimerStatus.running ? 'Pause' : 'Start'),
          );
        },
        error: (error, stack) => const Text('Error loading timer state'),
        loading: () => Text('Start')
    );
  }
}
