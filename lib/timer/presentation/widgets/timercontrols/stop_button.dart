import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../../domain/timer_state.dart';

class StopButton extends ConsumerWidget {
  const StopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Directly watch the TimerState
    final timerState = ref.watch(timerStateProvider);

    // Read the timerService
    final timerService = ref.read(timerProvider);

    // Determine if the button should be enabled
    final isStopEnabled = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;

    return ElevatedButton(
      onPressed: isStopEnabled ? () => timerService.stop() : null,
      child: const Text('Stop'),
    );
  }
}
