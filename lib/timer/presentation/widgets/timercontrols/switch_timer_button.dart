import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class SwitchTimerButton extends ConsumerWidget {
  const SwitchTimerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final timerStateAsync = ref.watch(timerStateProvider);
    final timerService = ref.read(timerProvider);

    return timerStateAsync.when(
      data: (timerState) {
        final TimerType newTimerType = timerState.timerType == TimerType.work
            ? TimerType.rest
            : TimerType.work;

        return ElevatedButton(
          onPressed: () => timerService.setTimerType(newTimerType),
          child: Text(timerState.timerType == TimerType.work
              ? 'Switch to Rest'
              : 'Switch to Work'),
        );
      },
      loading: () => const Text('Loading timer state...'),
      error: (error, stack) => const Text('Error loading timer state')
    );
  }
}
