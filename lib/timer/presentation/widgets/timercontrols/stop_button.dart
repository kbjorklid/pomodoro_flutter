import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class StopButton extends ConsumerWidget {
  const StopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(timerStateProvider);
    final timerService = ref.read(timerProvider);

    return timerStateAsync.when(
      data: (TimerState timerState) {
        final isStopEnabled = timerState.status == TimerStatus.running ||
            timerState.status == TimerStatus.paused;

        return ElevatedButton(
          onPressed: isStopEnabled ? () => timerService.stop() : null,
          child: const Text('Stop'),
        );
      },
      loading: () => ElevatedButton(
        onPressed: null,
        child: const Text('Stop'),
      ),
      error: (Object error, StackTrace stackTrace) => ElevatedButton(
        onPressed: null,
        child: const Text('Error'),
      ),
    );
  }
}
